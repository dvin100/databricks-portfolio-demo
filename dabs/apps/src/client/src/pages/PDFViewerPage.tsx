import { useState, useEffect } from 'react';
import { fetcher } from '@/lib/utils';
import { SidebarToggle } from '@/components/sidebar-toggle';

interface PDFFile {
  name: string;
  path: string;
}

export default function PDFViewerPage() {
  const [pdfFiles, setPdfFiles] = useState<PDFFile[]>([]);
  const [selectedPdf, setSelectedPdf] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Fetch list of PDF files from the backend
    fetcher('/api/pdf/list')
      .then((data: PDFFile[]) => {
        setPdfFiles(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message || 'Failed to load PDF files');
        setLoading(false);
      });
  }, []);

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
          <h1 className="font-semibold text-xl">PDF Documents</h1>
          <p className="text-muted-foreground text-xs">
            View and browse PDF files
          </p>
        </div>
      </div>
      <div className="flex flex-1 overflow-hidden">
        {/* PDF List Sidebar */}
        <div className="w-64 border-r bg-muted/20 overflow-y-auto">
          <div className="p-4">
            <h2 className="mb-4 font-semibold text-sm">Available PDFs</h2>
            {loading && (
              <div className="text-muted-foreground text-sm">Loading...</div>
            )}
            {error && (
              <div className="text-destructive text-sm">{error}</div>
            )}
            {!loading && !error && pdfFiles.length === 0 && (
              <div className="text-muted-foreground text-sm">No PDF files found</div>
            )}
            <div className="flex flex-col gap-1">
              {pdfFiles.map((file) => (
                <button
                  key={file.path}
                  onClick={() => setSelectedPdf(file.path)}
                  className={`rounded-md px-3 py-2 text-left text-sm transition-colors hover:bg-muted ${
                    selectedPdf === file.path
                      ? 'bg-primary text-primary-foreground'
                      : ''
                  }`}
                >
                  {file.name}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* PDF Viewer */}
        <div className="flex-1 overflow-hidden">
          {selectedPdf ? (
            <iframe
              src={`/api/pdf/view?path=${encodeURIComponent(selectedPdf)}`}
              width="100%"
              height="100%"
              frameBorder="0"
              title="PDF Viewer"
            />
          ) : (
            <div className="flex h-full items-center justify-center">
              <div className="text-center text-muted-foreground">
                <p className="text-lg">Select a PDF to view</p>
                <p className="text-sm">Choose a document from the list on the left</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}


