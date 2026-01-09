import {
  Router,
  type Request,
  type Response,
  type Router as RouterType,
} from 'express';
import { authMiddleware, requireAuth } from '../middleware/auth';
import { getLakebaseDb, isLakebaseAvailable } from '@chat-template/db';

export const lakebaseRouter: RouterType = Router();

// Apply auth middleware
lakebaseRouter.use(authMiddleware);

/**
 * GET /api/lakebase/users - Get users from lakebase_demo database
 */
lakebaseRouter.get('/users', requireAuth, async (req: Request, res: Response) => {
  console.log('[/api/lakebase/users] Handler called');

  // Return 204 No Content if database is not available
  const dbAvailable = isLakebaseAvailable();
  console.log('[/api/lakebase/users] Database available:', dbAvailable);

  if (!dbAvailable) {
    console.log('[/api/lakebase/users] Returning 204 No Content');
    return res.status(204).end();
  }

  try {
    console.log('[/api/lakebase/users] Getting lakebase database connection');
    const sql = await getLakebaseDb();

    // Query the users table - include a unique identifier (row number for now)
    const users = await sql`
      SELECT ROW_NUMBER() OVER (ORDER BY name) as id, name, dob, phone 
      FROM users 
      ORDER BY name
    `;
    
    console.log(`[/api/lakebase/users] Found ${users.length} users`);
    
    res.json({ users });
  } catch (error) {
    console.error('[/api/lakebase/users] Error:', error);
    res.status(500).json({ 
      error: 'Failed to fetch users',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * POST /api/lakebase/users - Create a new user in lakebase_demo database
 */
lakebaseRouter.post('/users', requireAuth, async (req: Request, res: Response) => {
  const { name, dob, phone } = req.body;

  console.log('[/api/lakebase/users POST] Create new user:', name);

  // Check database availability
  if (!isLakebaseAvailable()) {
    return res.status(503).json({
      error: 'Database unavailable',
      message: 'Lakebase database is not configured'
    });
  }

  // Validate input
  if (!name || !dob || !phone) {
    return res.status(400).json({ 
      error: 'Invalid input',
      message: 'name, dob, and phone are required'
    });
  }

  try {
    const sql = await getLakebaseDb();

    // Insert the new user
    const result = await sql`
      INSERT INTO users (name, dob, phone)
      VALUES (${name}, ${dob}, ${phone})
      RETURNING name, dob, phone
    `;

    console.log(`[/api/lakebase/users POST] Created user: ${name}`);
    res.status(201).json({ user: result[0], success: true });
  } catch (error) {
    console.error('[/api/lakebase/users POST] Error:', error);
    
    // Check for unique constraint violation or other DB errors
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    if (errorMessage.includes('duplicate') || errorMessage.includes('unique')) {
      return res.status(409).json({
        error: 'User already exists',
        message: `A user with name "${name}" already exists`
      });
    }
    
    res.status(500).json({ 
      error: 'Failed to create user',
      message: errorMessage
    });
  }
});

/**
 * PUT /api/lakebase/users/:name - Update a user in lakebase_demo database
 */
lakebaseRouter.put('/users/:name', requireAuth, async (req: Request, res: Response) => {
  const originalName = req.params.name;
  const { name, dob, phone } = req.body;

  console.log('[/api/lakebase/users PUT] Update user:', originalName);

  // Check database availability
  if (!isLakebaseAvailable()) {
    return res.status(503).json({
      error: 'Database unavailable',
      message: 'Lakebase database is not configured'
    });
  }

  // Validate input
  if (!name || !dob || !phone) {
    return res.status(400).json({ 
      error: 'Invalid input',
      message: 'name, dob, and phone are required'
    });
  }

  try {
    const sql = await getLakebaseDb();

    // Update the user - use the original name as identifier
    const result = await sql`
      UPDATE users 
      SET name = ${name}, dob = ${dob}, phone = ${phone}
      WHERE name = ${originalName}
      RETURNING name, dob, phone
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        error: 'User not found',
        message: `No user found with name: ${originalName}`
      });
    }

    console.log(`[/api/lakebase/users PUT] Updated user: ${originalName}`);
    res.json({ user: result[0], success: true });
  } catch (error) {
    console.error('[/api/lakebase/users PUT] Error:', error);
    res.status(500).json({ 
      error: 'Failed to update user',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * DELETE /api/lakebase/users/:name - Delete a user from lakebase_demo database
 */
lakebaseRouter.delete('/users/:name', requireAuth, async (req: Request, res: Response) => {
  const name = req.params.name;

  console.log('[/api/lakebase/users DELETE] Delete user:', name);

  // Check database availability
  if (!isLakebaseAvailable()) {
    return res.status(503).json({
      error: 'Database unavailable',
      message: 'Lakebase database is not configured'
    });
  }

  try {
    const sql = await getLakebaseDb();

    // Delete the user
    const result = await sql`
      DELETE FROM users 
      WHERE name = ${name}
      RETURNING name
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        error: 'User not found',
        message: `No user found with name: ${name}`
      });
    }

    console.log(`[/api/lakebase/users DELETE] Deleted user: ${name}`);
    res.json({ success: true, message: `User ${name} deleted successfully` });
  } catch (error) {
    console.error('[/api/lakebase/users DELETE] Error:', error);
    res.status(500).json({ 
      error: 'Failed to delete user',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});
