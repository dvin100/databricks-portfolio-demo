import { SidebarToggle } from '@/components/sidebar-toggle';
import { useEffect, useState } from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Pencil, Check, X, Trash2, Plus } from 'lucide-react';

interface User {
  id?: number;
  name: string;
  dob: string;
  phone: string;
}

interface EditingUser {
  originalName: string;
  name: string;
  dob: string;
  phone: string;
}

interface NewUser {
  name: string;
  dob: string;
  phone: string;
}

export default function LakebasePage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editingUser, setEditingUser] = useState<EditingUser | null>(null);
  const [saving, setSaving] = useState(false);
  const [deletingUser, setDeletingUser] = useState<string | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [newUser, setNewUser] = useState<NewUser>({
    name: '',
    dob: '',
    phone: '',
  });

  const fetchUsers = async (showLoadingState = true) => {
    try {
      if (showLoadingState) {
        setLoading(true);
      }
      const response = await fetch('/api/lakebase/users', {
        credentials: 'include',
      });

      if (!response.ok) {
        throw new Error('Failed to fetch users');
      }

      const data = await response.json();
      setUsers(data.users);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      if (showLoadingState) {
        setLoading(false);
      }
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleEdit = (user: User) => {
    setEditingUser({
      originalName: user.name,
      name: user.name,
      dob: user.dob.split('T')[0], // Format date for input
      phone: user.phone,
    });
  };

  const handleCancel = () => {
    setEditingUser(null);
  };

  const handleSave = async () => {
    if (!editingUser) return;

    // Optimistic update - update UI immediately
    const updatedUsers = users.map(user => 
      user.name === editingUser.originalName
        ? { ...user, name: editingUser.name, dob: editingUser.dob, phone: editingUser.phone }
        : user
    );
    const previousUsers = users;
    setUsers(updatedUsers);
    setEditingUser(null);

    setSaving(true);
    try {
      const response = await fetch(`/api/lakebase/users/${encodeURIComponent(editingUser.originalName)}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify({
          name: editingUser.name,
          dob: editingUser.dob,
          phone: editingUser.phone,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        // Rollback on error
        setUsers(previousUsers);
        throw new Error(errorData.message || 'Failed to update user');
      }

      // Silently sync with server to ensure consistency
      fetchUsers(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to save changes');
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (field: keyof EditingUser, value: string) => {
    if (editingUser) {
      setEditingUser({
        ...editingUser,
        [field]: value,
      });
    }
  };

  const handleDeleteClick = (user: User) => {
    setDeletingUser(user.name);
    setShowDeleteDialog(true);
  };

  const handleDeleteConfirm = async () => {
    if (!deletingUser) return;

    // Optimistic update - remove from UI immediately
    const previousUsers = users;
    setUsers(users.filter(user => user.name !== deletingUser));
    setShowDeleteDialog(false);
    const userToDelete = deletingUser;
    setDeletingUser(null);

    try {
      const response = await fetch(`/api/lakebase/users/${encodeURIComponent(userToDelete)}`, {
        method: 'DELETE',
        credentials: 'include',
      });

      if (!response.ok) {
        const errorData = await response.json();
        // Rollback on error
        setUsers(previousUsers);
        throw new Error(errorData.message || 'Failed to delete user');
      }

      // Silently sync with server to ensure consistency
      fetchUsers(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete user');
    }
  };

  const handleDeleteCancel = () => {
    setShowDeleteDialog(false);
    setDeletingUser(null);
  };

  const handleNewUserChange = (field: keyof NewUser, value: string) => {
    setNewUser({
      ...newUser,
      [field]: value,
    });
  };

  const handleAddUser = async () => {
    // Validate input
    if (!newUser.name || !newUser.dob || !newUser.phone) {
      setError('All fields are required');
      return;
    }

    // Optimistic update - add to UI immediately
    const previousUsers = users;
    const optimisticUser: User = {
      name: newUser.name,
      dob: newUser.dob,
      phone: newUser.phone,
    };
    setUsers([...users, optimisticUser]);
    setShowAddDialog(false);
    const userToAdd = { ...newUser };
    setNewUser({ name: '', dob: '', phone: '' });
    setError(null);

    setSaving(true);
    try {
      const response = await fetch('/api/lakebase/users', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include',
        body: JSON.stringify(userToAdd),
      });

      if (!response.ok) {
        const errorData = await response.json();
        // Rollback on error
        setUsers(previousUsers);
        throw new Error(errorData.message || 'Failed to create user');
      }

      // Silently sync with server to ensure consistency
      fetchUsers(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add user');
    } finally {
      setSaving(false);
    }
  };

  const handleAddDialogOpenChange = (open: boolean) => {
    setShowAddDialog(open);
    if (!open) {
      // Reset form when closing
      setNewUser({ name: '', dob: '', phone: '' });
      setError(null);
    }
  };

  return (
    <div className="flex h-screen w-full flex-col">
      <div className="sticky top-0 flex items-center gap-3 border-b bg-background px-4 py-3">
        <SidebarToggle />
        <h2 className="font-semibold text-lg">Lakebase</h2>
      </div>
      <div className="flex flex-1 flex-col overflow-auto p-6">
        <div className="mb-6 flex items-center justify-between">
          <div>
            <h1 className="mb-2 font-semibold text-3xl">Lakebase Demo</h1>
            <p className="text-muted-foreground">
              Users from lakebase_demo.users database (click edit to modify)
            </p>
          </div>
          <Button onClick={() => setShowAddDialog(true)} className="gap-2">
            <Plus className="h-4 w-4" />
            Add User
          </Button>
        </div>

        {loading && (
          <div className="flex items-center justify-center py-8">
            <p className="text-muted-foreground">Loading users...</p>
          </div>
        )}

        {error && (
          <div className="mb-4 rounded-md border border-red-500 bg-red-50 p-4 dark:bg-red-950">
            <p className="text-red-600 dark:text-red-400">Error: {error}</p>
          </div>
        )}

        {!loading && users.length > 0 && (
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Name</TableHead>
                  <TableHead>Date of Birth</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead className="w-[140px]">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users.map((user, index) => {
                  const isEditing = editingUser?.originalName === user.name;
                  
                  return (
                    <TableRow key={index}>
                      <TableCell className="font-medium">
                        {isEditing ? (
                          <Input
                            value={editingUser.name}
                            onChange={(e) => handleChange('name', e.target.value)}
                            className="h-8"
                            disabled={saving}
                          />
                        ) : (
                          user.name
                        )}
                      </TableCell>
                      <TableCell>
                        {isEditing ? (
                          <Input
                            type="date"
                            value={editingUser.dob}
                            onChange={(e) => handleChange('dob', e.target.value)}
                            className="h-8"
                            disabled={saving}
                          />
                        ) : (
                          new Date(user.dob).toLocaleDateString()
                        )}
                      </TableCell>
                      <TableCell>
                        {isEditing ? (
                          <Input
                            value={editingUser.phone}
                            onChange={(e) => handleChange('phone', e.target.value)}
                            className="h-8"
                            disabled={saving}
                          />
                        ) : (
                          user.phone
                        )}
                      </TableCell>
                      <TableCell>
                        {isEditing ? (
                          <div className="flex gap-2">
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={handleSave}
                              disabled={saving}
                              className="h-8 w-8 p-0"
                            >
                              <Check className="h-4 w-4 text-green-600" />
                            </Button>
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={handleCancel}
                              disabled={saving}
                              className="h-8 w-8 p-0"
                            >
                              <X className="h-4 w-4 text-red-600" />
                            </Button>
                          </div>
                        ) : (
                          <div className="flex gap-2">
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => handleEdit(user)}
                              disabled={editingUser !== null}
                              className="h-8 w-8 p-0"
                              title="Edit user"
                            >
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => handleDeleteClick(user)}
                              disabled={editingUser !== null}
                              className="h-8 w-8 p-0"
                              title="Delete user"
                            >
                              <Trash2 className="h-4 w-4 text-red-600" />
                            </Button>
                          </div>
                        )}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        )}

        {!loading && users.length === 0 && (
          <div className="flex items-center justify-center py-8">
            <p className="text-muted-foreground">No users found</p>
          </div>
        )}
      </div>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
            <AlertDialogDescription>
              This will permanently delete the user "{deletingUser}" from the database.
              This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={handleDeleteCancel}>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteConfirm} className="bg-red-600 hover:bg-red-700">
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Add User Dialog */}
      <AlertDialog open={showAddDialog} onOpenChange={handleAddDialogOpenChange}>
        <AlertDialogContent className="sm:max-w-[425px]">
          <AlertDialogHeader>
            <AlertDialogTitle>Add New User</AlertDialogTitle>
            <AlertDialogDescription>
              Enter the details for the new user below.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <label htmlFor="add-name" className="text-sm font-medium">
                Name
              </label>
              <Input
                id="add-name"
                placeholder="Enter name"
                value={newUser.name}
                onChange={(e) => handleNewUserChange('name', e.target.value)}
                disabled={saving}
              />
            </div>
            <div className="grid gap-2">
              <label htmlFor="add-dob" className="text-sm font-medium">
                Date of Birth
              </label>
              <Input
                id="add-dob"
                type="date"
                value={newUser.dob}
                onChange={(e) => handleNewUserChange('dob', e.target.value)}
                disabled={saving}
              />
            </div>
            <div className="grid gap-2">
              <label htmlFor="add-phone" className="text-sm font-medium">
                Phone
              </label>
              <Input
                id="add-phone"
                placeholder="555-0123"
                value={newUser.phone}
                onChange={(e) => handleNewUserChange('phone', e.target.value)}
                disabled={saving}
              />
            </div>
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={() => setShowAddDialog(false)} disabled={saving}>
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleAddUser}
              disabled={saving || !newUser.name || !newUser.dob || !newUser.phone}
            >
              {saving ? 'Adding...' : 'Add User'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
