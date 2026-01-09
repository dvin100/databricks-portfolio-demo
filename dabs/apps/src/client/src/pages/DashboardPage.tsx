import { SidebarToggle } from '@/components/sidebar-toggle';

export default function DashboardPage() {
  return (
    <div className="flex h-screen w-full flex-col">
      <div className="sticky top-0 flex items-center gap-4 border-b bg-background px-4 py-3">
        <SidebarToggle />
        <img 
          src="/databricks-logo.png" 
          alt="Databricks" 
          className="h-auto"
          style={{ width: '100px' }}
        />
        <div className="flex flex-col">
          <h1 className="font-semibold text-xl">Dashboard</h1>
          <p className="text-muted-foreground text-xs">
            Analytics Dashboard
          </p>
        </div>
      </div>
      <div className="flex-1 overflow-hidden">
        <iframe src="https://dbc-7b7cc9ff-3ad5.cloud.databricks.com/embed/dashboardsv3/01f0ecb8c2df1e39948be59411eb8f31"
          width="100%"
          height="100%"
          frameBorder="0"
          title="Databricks Dashboard"
        />
      </div>
    </div>
  );
}


