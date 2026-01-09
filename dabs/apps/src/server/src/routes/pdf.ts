import {
  Router,
  type Request,
  type Response,
  type Router as RouterType,
} from 'express';
import { getDatabricksToken } from '@chat-template/auth';
import { getHostUrl } from '@chat-template/utils';

export const pdfRouter: RouterType = Router();

// Unity Catalog volume configuration
const CATALOG = 'demo';
const SCHEMA = 'portfolio';
const VOLUME = 'artifacts/pdf';
const VOLUME_PATH = `/Volumes/${CATALOG}/${SCHEMA}/${VOLUME}`;

/**
 * GET /api/pdf/list - List all PDF files in the Unity Catalog volume
 */
pdfRouter.get('/list', async (_req: Request, res: Response) => {
  try {
    const token = await getDatabricksToken();
    const host = getHostUrl();

    // Use Databricks Files API to list files in the Unity Catalog volume
    const response = await fetch(
      `${host}/api/2.0/fs/directories${VOLUME_PATH}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`Failed to list files. Status: ${response.status}, Response: ${errorText}`);
      throw new Error(`Failed to list files: ${response.statusText}`);
    }

    const data = await response.json();
    
    // Filter for PDF files only
    const pdfFiles = (data.contents || [])
      .filter((file: any) => file.name.toLowerCase().endsWith('.pdf'))
      .map((file: any) => ({
        name: file.name,
        path: file.path,
      }));

    res.json(pdfFiles);
  } catch (error) {
    console.error('Error listing PDF files:', error);
    res.status(500).json({ 
      error: 'Failed to list PDF files',
      message: error instanceof Error ? error.message : 'Unknown error',
      volumePath: VOLUME_PATH
    });
  }
});

/**
 * GET /api/pdf/view - Stream a PDF file for viewing from Unity Catalog volume
 */
pdfRouter.get('/view', async (req: Request, res: Response) => {
  try {
    const { path } = req.query;

    if (!path || typeof path !== 'string') {
      res.status(400).json({ error: 'Path parameter is required' });
      return;
    }

    const token = await getDatabricksToken();
    const host = getHostUrl();

    // Fetch the PDF file from Databricks Unity Catalog volume
    const response = await fetch(
      `${host}/api/2.0/fs/files${path}`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`Failed to fetch PDF. Status: ${response.status}, Response: ${errorText}`);
      throw new Error(`Failed to fetch PDF: ${response.statusText}`);
    }

    // Set appropriate headers for PDF viewing
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'inline');

    // Stream the PDF to the client
    const buffer = await response.arrayBuffer();
    res.send(Buffer.from(buffer));
  } catch (error) {
    console.error('Error fetching PDF file:', error);
    res.status(500).json({ 
      error: 'Failed to fetch PDF file',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

