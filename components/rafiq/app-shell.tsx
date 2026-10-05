'use client'

import { ArrowRight, Settings } from 'lucide-react'
import { AppStateProvider, useAppState } from './app-state'
import { BottomNav } from './bottom-nav'
import { PrayerScreen } from './screens/prayer-screen'
import { AdhkarScreen } from './screens/adhkar-screen'
import { QuranScreen } from './screens/quran-screen'
import { LibraryScreen } from './screens/library-screen'
import { ProgressScreen } from './screens/progress-screen'
import { SettingsScreen } from './screens/settings-screen'
import { FONT_SIZES } from '@/lib/rafiq-data'

export function AppShell() {
  return (
    <AppStateProvider>
      <div className="flex min-h-dvh items-center justify-center bg-[#efe9dc] md:p-8">
        <Device />
      </div>
    </AppStateProvider>
  )
}

function Device() {
  const { darkMode, fontSizeIndex } = useAppState()

  return (
    <div
      className={`${darkMode ? 'dark' : ''} relative w-full md:w-[400px]`}
      style={{ ['--text-scale' as string]: FONT_SIZES[fontSizeIndex].scale }}
    >
      <div className="relative flex h-dvh flex-col overflow-hidden bg-background text-foreground md:h-[844px] md:rounded-[48px] md:border-[10px] md:border-[#14211c] md:shadow-[0_40px_80px_-30px_rgb(15_56_44/0.5)]">
        <StatusBar />
        <TopBar />
        <main className="no-scrollbar flex-1 overflow-y-auto pb-28">
          <ActiveScreen />
        </main>
        <BottomNav />
      </div>
    </div>
  )
}

function StatusBar() {
  return (
    <div
      className="hidden items-center justify-between px-8 pt-3 pb-1 text-xs font-medium text-foreground md:flex"
      dir="ltr"
      aria-hidden="true"
    >
      <span>9:41</span>
      <span className="h-6 w-24 rounded-full bg-[#14211c]" />
      <span className="flex items-center gap-1">
        <span className="h-2.5 w-4 rounded-sm border border-current" />
      </span>
    </div>
  )
}

function TopBar() {
  const { settingsOpen, setSettingsOpen } = useAppState()

  return (
    <header className="grid grid-cols-[40px_1fr_40px] items-center px-4 pt-3 pb-2">
      {settingsOpen ? (
        <button
          type="button"
          onClick={() => setSettingsOpen(false)}
          className="flex size-10 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted"
          aria-label="رجوع"
        >
          <ArrowRight className="size-5" />
        </button>
      ) : (
        <span />
      )}
      <h1 className="text-center text-lg font-semibold text-primary">
        {settingsOpen ? 'الإعدادات' : 'رفيق المسلم'}
      </h1>
      {settingsOpen ? (
        <span />
      ) : (
        <button
          type="button"
          onClick={() => setSettingsOpen(true)}
          className="flex size-10 items-center justify-center rounded-full text-foreground transition-colors hover:bg-muted"
          aria-label="الإعدادات"
        >
          <Settings className="size-5" />
        </button>
      )}
    </header>
  )
}

function ActiveScreen() {
  const { tab, settingsOpen } = useAppState()
  if (settingsOpen) return <SettingsScreen />

  return (
    <div key={tab} className="animate-in fade-in slide-in-from-bottom-2 duration-300">
      {tab === 'prayer' && <PrayerScreen />}
      {tab === 'adhkar' && <AdhkarScreen />}
      {tab === 'quran' && <QuranScreen />}
      {tab === 'library' && <LibraryScreen />}
      {tab === 'progress' && <ProgressScreen />}
    </div>
  )
}
