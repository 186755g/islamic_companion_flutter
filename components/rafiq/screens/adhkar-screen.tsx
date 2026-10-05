'use client'

import { useState } from 'react'
import { Check, RotateCcw } from 'lucide-react'
import { useAppState } from '../app-state'
import { ADHKAR, ADHKAR_TABS, type AdhkarCategory, type Dhikr, toArabicDigits } from '@/lib/rafiq-data'

export function AdhkarScreen() {
  const [category, setCategory] = useState<AdhkarCategory>('morning')
  const { dhikrCounts, resetAdhkar } = useAppState()
  const list = ADHKAR[category]
  const doneCount = list.filter((d) => (dhikrCounts[d.id] ?? 0) >= d.repeat).length
  const progress = doneCount / list.length

  return (
    <div className="flex flex-col gap-4 px-4 pt-2">
      <div role="tablist" aria-label="تصنيف الأذكار" className="grid grid-cols-3 gap-1 rounded-2xl bg-muted p-1">
        {ADHKAR_TABS.map((t) => {
          const active = t.id === category
          return (
            <button
              key={t.id}
              type="button"
              role="tab"
              aria-selected={active}
              onClick={() => setCategory(t.id)}
              className={`rounded-xl py-2.5 text-sm font-medium transition-all ${
                active ? 'bg-card text-primary soft-shadow' : 'text-muted-foreground hover:text-foreground'
              }`}
            >
              {`أذكار ${t.label}`}
            </button>
          )
        })}
      </div>

      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between text-xs">
          <span className="text-muted-foreground">
            {`أنجزت ${toArabicDigits(doneCount)} من ${toArabicDigits(list.length)} أذكار`}
          </span>
          <button
            type="button"
            onClick={() => resetAdhkar(category)}
            className="flex items-center gap-1 font-medium text-primary hover:underline"
          >
            <RotateCcw className="size-3.5" aria-hidden="true" />
            إعادة تعيين
          </button>
        </div>
        <div
          className="h-1.5 overflow-hidden rounded-full bg-muted"
          role="progressbar"
          aria-label="تقدم الأذكار"
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={Math.round(progress * 100)}
        >
          <div
            className="h-full rounded-full bg-primary transition-all duration-500"
            style={{ width: `${progress * 100}%` }}
          />
        </div>
      </div>

      <ul key={category} className="flex flex-col gap-4 animate-in fade-in duration-300">
        {list.map((d) => (
          <DhikrCard key={d.id} dhikr={d} />
        ))}
      </ul>
    </div>
  )
}

function DhikrCard({ dhikr }: { dhikr: Dhikr }) {
  const { dhikrCounts, incrementDhikr } = useAppState()
  const count = dhikrCounts[dhikr.id] ?? 0
  const remaining = dhikr.repeat - count
  const done = remaining <= 0

  return (
    <li
      className={`rounded-3xl border bg-card p-5 soft-shadow transition-colors ${
        done ? 'border-primary/30' : 'border-transparent'
      }`}
    >
      <p
        className="font-quran leading-[2.2] text-foreground text-pretty"
        style={{ fontSize: 'calc(1.375rem * var(--text-scale, 1))' }}
      >
        {dhikr.text}
      </p>
      {dhikr.virtue && (
        <p className="mt-3 rounded-xl bg-muted px-3 py-2 text-xs leading-relaxed text-muted-foreground">
          {dhikr.virtue}
        </p>
      )}
      <div className="mt-4 flex items-center justify-between gap-3 border-t border-dashed pt-4">
        <span className="text-xs text-muted-foreground">{dhikr.source}</span>
        {done ? (
          <span className="flex items-center gap-1.5 rounded-full bg-primary px-4 py-2 text-sm font-medium text-primary-foreground animate-in zoom-in-75 duration-300">
            <Check className="size-4" strokeWidth={3} aria-hidden="true" />
            تم
          </span>
        ) : (
          <button
            type="button"
            onClick={() => incrementDhikr(dhikr.id)}
            className="flex items-center gap-2 rounded-full bg-gold-soft px-4 py-2 text-sm font-semibold text-accent-foreground transition-transform active:scale-95"
            aria-label={`تسبيح، متبقي ${remaining}`}
          >
            <span className="flex size-6 items-center justify-center rounded-full bg-gold text-[11px] font-bold text-[#0F382C] tabular-nums">
              {toArabicDigits(remaining)}
            </span>
            متبقي
          </button>
        )}
      </div>
    </li>
  )
}
