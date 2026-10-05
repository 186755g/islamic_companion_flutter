'use client'

import { BookOpen, ChartColumn, HandHeart, LibraryBig, MoonStar } from 'lucide-react'
import { type Tab, useAppState } from './app-state'

const ITEMS: { id: Tab; label: string; Icon: typeof MoonStar }[] = [
  { id: 'prayer', label: 'الصلاة', Icon: MoonStar },
  { id: 'adhkar', label: 'الأذكار', Icon: HandHeart },
  { id: 'quran', label: 'القرآن', Icon: BookOpen },
  { id: 'library', label: 'المكتبة', Icon: LibraryBig },
  { id: 'progress', label: 'التقدم', Icon: ChartColumn },
]

export function BottomNav() {
  const { tab, setTab, settingsOpen, setSettingsOpen } = useAppState()

  return (
    <nav
      aria-label="التنقل الرئيسي"
      className="absolute inset-x-3 bottom-3 rounded-[28px] border border-border bg-card/95 px-2 py-2 soft-shadow backdrop-blur"
    >
      <ul className="flex items-stretch justify-between">
        {ITEMS.map(({ id, label, Icon }) => {
          const active = !settingsOpen && tab === id
          return (
            <li key={id} className="flex-1">
              <button
                type="button"
                onClick={() => {
                  setSettingsOpen(false)
                  setTab(id)
                }}
                aria-current={active ? 'page' : undefined}
                className="group flex w-full flex-col items-center gap-1 py-1"
              >
                <span
                  className={`flex h-8 w-14 items-center justify-center rounded-full transition-all duration-300 ${
                    active ? 'bg-primary/10 text-primary' : 'text-muted-foreground group-hover:text-foreground'
                  }`}
                >
                  <Icon
                    className="size-5"
                    strokeWidth={active ? 2.4 : 1.8}
                    fill={active ? 'currentColor' : 'none'}
                    fillOpacity={active ? 0.18 : 0}
                  />
                </span>
                <span
                  className={`text-[11px] transition-colors ${
                    active ? 'font-semibold text-primary' : 'text-muted-foreground'
                  }`}
                >
                  {label}
                </span>
              </button>
            </li>
          )
        })}
      </ul>
    </nav>
  )
}
