'use client'

import { createContext, useCallback, useContext, useMemo, useState } from 'react'
import { ADHKAR, type AdhkarCategory, POINTS } from '@/lib/rafiq-data'

export type Tab = 'prayer' | 'adhkar' | 'quran' | 'library' | 'progress'

type KhatmaPlan = { days: number; pagesPerDay: number }

type AppState = {
  tab: Tab
  setTab: (tab: Tab) => void
  settingsOpen: boolean
  setSettingsOpen: (open: boolean) => void
  darkMode: boolean
  setDarkMode: (value: boolean) => void
  fontSizeIndex: number
  setFontSizeIndex: (value: number) => void

  fardDone: Set<string>
  sunnahDone: Set<string>
  toggleFard: (id: string) => void
  toggleSunnah: (id: string) => void

  dhikrCounts: Record<string, number>
  incrementDhikr: (id: string) => void
  resetAdhkar: (category: AdhkarCategory) => void
  completedSessions: number

  quranPage: number
  readPage: () => void
  khatmaPlan: KhatmaPlan | null
  setKhatmaPlan: (plan: KhatmaPlan | null) => void

  points: number
  streak: { current: number; longest: number; activeDays: number }
}

const AppStateContext = createContext<AppState | null>(null)

const toggleIn = (set: Set<string>, id: string) => {
  const next = new Set(set)
  if (next.has(id)) next.delete(id)
  else next.add(id)
  return next
}

export function AppStateProvider({ children }: { children: React.ReactNode }) {
  const [tab, setTab] = useState<Tab>('prayer')
  const [settingsOpen, setSettingsOpen] = useState(false)
  const [darkMode, setDarkMode] = useState(false)
  const [fontSizeIndex, setFontSizeIndex] = useState(1)
  const [fardDone, setFardDone] = useState<Set<string>>(() => new Set(['fajr', 'dhuhr']))
  const [sunnahDone, setSunnahDone] = useState<Set<string>>(() => new Set(['fajr-sunnah']))
  const [dhikrCounts, setDhikrCounts] = useState<Record<string, number>>({})
  const [quranPage, setQuranPage] = useState(0)
  const [khatmaPlan, setKhatmaPlan] = useState<KhatmaPlan | null>(null)

  const toggleFard = useCallback((id: string) => setFardDone((s) => toggleIn(s, id)), [])
  const toggleSunnah = useCallback((id: string) => setSunnahDone((s) => toggleIn(s, id)), [])

  const incrementDhikr = useCallback((id: string) => {
    const dhikr = Object.values(ADHKAR)
      .flat()
      .find((d) => d.id === id)
    if (!dhikr) return
    setDhikrCounts((c) => ({ ...c, [id]: Math.min((c[id] ?? 0) + 1, dhikr.repeat) }))
  }, [])

  const resetAdhkar = useCallback((category: AdhkarCategory) => {
    setDhikrCounts((c) => {
      const next = { ...c }
      for (const d of ADHKAR[category]) delete next[d.id]
      return next
    })
  }, [])

  const readPage = useCallback(() => setQuranPage((p) => Math.min(p + 1, 604)), [])

  const completedSessions = useMemo(
    () =>
      (Object.keys(ADHKAR) as AdhkarCategory[]).filter((cat) =>
        ADHKAR[cat].every((d) => (dhikrCounts[d.id] ?? 0) >= d.repeat),
      ).length,
    [dhikrCounts],
  )

  const points =
    fardDone.size * POINTS.fard +
    sunnahDone.size * POINTS.sunnah +
    completedSessions * POINTS.adhkarSession +
    quranPage * POINTS.quranPage

  const allFard = fardDone.size === 5
  const streak = {
    current: 6 + (allFard ? 1 : 0),
    longest: 21,
    activeDays: 47 + (fardDone.size > 0 ? 1 : 0),
  }

  const value: AppState = {
    tab,
    setTab,
    settingsOpen,
    setSettingsOpen,
    darkMode,
    setDarkMode,
    fontSizeIndex,
    setFontSizeIndex,
    fardDone,
    sunnahDone,
    toggleFard,
    toggleSunnah,
    dhikrCounts,
    incrementDhikr,
    resetAdhkar,
    completedSessions,
    quranPage,
    readPage,
    khatmaPlan,
    setKhatmaPlan,
    points,
    streak,
  }

  return <AppStateContext.Provider value={value}>{children}</AppStateContext.Provider>
}

export function useAppState() {
  const ctx = useContext(AppStateContext)
  if (!ctx) throw new Error('useAppState must be used within AppStateProvider')
  return ctx
}
