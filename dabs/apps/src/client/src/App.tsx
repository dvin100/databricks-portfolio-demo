import { Routes, Route } from 'react-router-dom';
import { ThemeProvider } from '@/components/theme-provider';
import { SessionProvider } from '@/contexts/SessionContext';
import { AppConfigProvider } from '@/contexts/AppConfigContext';
import { DataStreamProvider } from '@/components/data-stream-provider';
import { Toaster } from 'sonner';
import RootLayout from '@/layouts/RootLayout';
import ChatLayout from '@/layouts/ChatLayout';
import HomePage from '@/pages/HomePage';
import NewChatPage from '@/pages/NewChatPage';
import ChatPage from '@/pages/ChatPage';
import DashboardPage from '@/pages/DashboardPage';
import PDFViewerPage from '@/pages/PDFViewerPage';
import NewsPage from '@/pages/NewsPage';
import LakebasePage from '@/pages/LakebasePage';

function App() {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      <SessionProvider>
        <AppConfigProvider>
          <DataStreamProvider>
            <Toaster position="top-center" />
            <Routes>
              <Route path="/" element={<RootLayout />}>
                <Route element={<ChatLayout />}>
                  <Route index element={<HomePage />} />
                  <Route path="dashboard" element={<DashboardPage />} />
                  <Route path="chat" element={<NewChatPage />} />
                  <Route path="chat/:id" element={<ChatPage />} />
                  <Route path="news" element={<NewsPage />} />
                  <Route path="documents" element={<PDFViewerPage />} />
                  <Route path="lakebase" element={<LakebasePage />} />
                </Route>
              </Route>
            </Routes>
          </DataStreamProvider>
        </AppConfigProvider>
      </SessionProvider>
    </ThemeProvider>
  );
}

export default App;
