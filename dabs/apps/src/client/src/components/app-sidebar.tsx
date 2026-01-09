import { useNavigate, useLocation } from 'react-router-dom';

import { SidebarHistory } from '@/components/sidebar-history';
import { SidebarUserNav } from '@/components/sidebar-user-nav';
import { Button } from '@/components/ui/button';
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  useSidebar,
} from '@/components/ui/sidebar';
import { Link } from 'react-router-dom';
import { Tooltip, TooltipContent, TooltipTrigger } from './ui/tooltip';
import { PlusIcon, MessageSquare, BarChart3, FileText, Newspaper, Home, Database } from 'lucide-react';
import type { ClientSession } from '@chat-template/auth';

export function AppSidebar({
  user,
  preferredUsername,
}: {
  user: ClientSession['user'] | undefined;
  preferredUsername: string | null;
}) {
  const { setOpenMobile } = useSidebar();
  const navigate = useNavigate();
  const location = useLocation();

  const isActivePath = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };

  return (
    <Sidebar className="group-data-[side=left]:border-r-0">
      <SidebarHeader>
        <SidebarMenu>
          <div className="flex flex-row items-center justify-between">
            <Link
              to="/"
              onClick={() => {
                setOpenMobile(false);
              }}
              className="flex flex-row items-center gap-3"
            >
              <span className="cursor-pointer rounded-md px-2 font-semibold text-lg hover:bg-muted">
                Databricks
              </span>
            </Link>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button
                  variant="ghost"
                  type="button"
                  className="h-8 p-1 md:h-fit md:p-2"
                  onClick={() => {
                    setOpenMobile(false);
                    navigate('/chat');
                  }}
                >
                  <PlusIcon />
                </Button>
              </TooltipTrigger>
              <TooltipContent align="end" className="hidden md:block">
                New Chat
              </TooltipContent>
            </Tooltip>
          </div>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu>
          <div className="flex flex-col gap-1 px-2 py-2">
            <Link
              to="/"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <Home className="size-4" />
              <span className="text-sm">Home</span>
            </Link>
            <Link
              to="/chat"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/chat') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <MessageSquare className="size-4" />
              <span className="text-sm">Chat</span>
            </Link>
            <Link
              to="/dashboard"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/dashboard') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <BarChart3 className="size-4" />
              <span className="text-sm">Dashboard</span>
            </Link>
            <Link
              to="/news"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/news') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <Newspaper className="size-4" />
              <span className="text-sm">News</span>
            </Link>
            <Link
              to="/documents"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/documents') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <FileText className="size-4" />
              <span className="text-sm">Documents</span>
            </Link>
            <Link
              to="/lakebase"
              onClick={() => {
                setOpenMobile(false);
              }}
              className={`flex flex-row items-center gap-3 rounded-md px-2 py-2 hover:bg-muted ${
                isActivePath('/lakebase') ? 'bg-muted font-semibold' : ''
              }`}
            >
              <Database className="size-4" />
              <span className="text-sm">Lakebase</span>
            </Link>
          </div>
        </SidebarMenu>
        <SidebarHistory user={user} />
      </SidebarContent>
      <SidebarFooter>
        {user && (
          <SidebarUserNav user={user} preferredUsername={preferredUsername} />
        )}
      </SidebarFooter>
    </Sidebar>
  );
}
