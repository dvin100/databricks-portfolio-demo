import { SidebarToggle } from '@/components/sidebar-toggle';

export default function HomePage() {
  return (
    <div className="flex h-screen w-full flex-col">
      <div className="sticky top-0 flex items-center gap-3 border-b bg-background px-4 py-3">
        <SidebarToggle />
        <h2 className="font-semibold text-lg">Home</h2>
      </div>
      <div className="flex flex-1 items-center justify-center">
        <div className="text-center">
          <div className="mb-8 flex justify-center">
            <img 
              src="/databricks-logo.png" 
              alt="Databricks" 
              className="h-auto"
              style={{ width: '250px' }}
            />
          </div>
          <h1 className="mb-4 font-semibold text-3xl md:text-4xl">
            Databricks Data Intelligence Platform
          </h1>
          <p className="text-xl text-muted-foreground md:text-2xl">
            Welcome to Databricks!
          </p>
        </div>
      </div>
    </div>
  );
}

