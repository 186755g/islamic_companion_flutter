'use client'

import { useState } from 'react'
import { BookOpen, Flag, Plus, Trash2 } from 'lucide-react'
import { useAppState } from '../app-state'
import { ProgressRing } from '../progress-ring'
import { QURAN_TOTAL_PAGES, toArabicDigits } from '@/lib/rafiq-data'

const PLAN_OPTIONS = [
  { days: 30, label: 'شهر واحد' },
  { days: 60, label: 'شهرين' },
  { days: 90, label: 'ثلاثة أشهر' },
]

export function QuranScreen() {
  const { quranPage, readPage } = useAppState()
  const progress = quranPage / QURAN_TOTAL_PAGES
  const juz = Math.min(30, Math.floor(quranPage / 20) + 1)

  return (
    <div className="flex flex-col gap-5 px-4 pt-2">
      <section className="islamic-pattern rounded-3xl bg-hero p-6 text-hero-foreground soft-shadow">
        <div className="flex flex-col items-center text-center">
          <ProgressRing value={progress} size={148} stroke={10} label="تقدم الختمة">
            <span className="text-4xl font-bold leading-none">{`${toArabicDigits(Math.round(progress * 100))}٪`}</span>
            <span className="mt-1.5 text-xs text-hero-foreground/70">من الختمة</span>
          </ProgressRing>
          <p className="mt-4 text-sm text-hero-foreground/80">
            {`صفحة ${toArabicDigits(quranPage)} من ${toArabicDigits(QURAN_TOTAL_PAGES)}`}
          </p>
          <p className="text-xs text-hero-foreground/60">
            {quranPage === 0 ? 'لم تبدأ القراءة بعد' : `الجزء ${toArabicDigits(juz)}`}
          </p>
          <button
            type="button"
            onClick={readPage}
            className="mt-5 flex w-full items-center justify-center gap-2 rounded-2xl bg-gold py-3.5 text-base font-semibold text-[#0F382C] transition-transform active:scale-[0.98]"
          >
            <BookOpen className="size-5" aria-hidden="true" />
            {quranPage === 0 ? 'ابدأ القراءة' : 'تابع القراءة'}
          </button>
        </div>
      </section>

      <KhatmaPlanSection />
    </div>
  )
}

function KhatmaPlanSection() {
  const { khatmaPlan, setKhatmaPlan, quranPage } = useAppState()
  const [choosing, setChoosing] = useState(false)

  if (khatmaPlan) {
    const target = khatmaPlan.pagesPerDay
    const todayRead = Math.min(quranPage, target)
    return (
      <section className="rounded-3xl bg-card p-5 soft-shadow" aria-labelledby="plan-heading">
        <div className="flex items-center justify-between">
          <h2 id="plan-heading" className="text-base font-semibold">
            خطة الختمة
          </h2>
          <button
            type="button"
            onClick={() => setKhatmaPlan(null)}
            className="flex size-8 items-center justify-center rounded-full text-muted-foreground hover:bg-muted"
            aria-label="حذف الخطة"
          >
            <Trash2 className="size-4" />
          </button>
        </div>
        <p className="mt-1 text-sm text-muted-foreground">
          {`ختمة في ${toArabicDigits(khatmaPlan.days)} يومًا · ${toArabicDigits(target)} صفحة يوميًا`}
        </p>
        <div className="mt-4 flex items-center justify-between text-xs">
          <span className="text-muted-foreground">ورد اليوم</span>
          <span className="font-semibold text-primary">{`${toArabicDigits(todayRead)}/${toArabicDigits(target)}`}</span>
        </div>
        <div className="mt-2 h-2 overflow-hidden rounded-full bg-muted">
          <div
            className="h-full rounded-full bg-gold transition-all duration-500"
            style={{ width: `${(todayRead / target) * 100}%` }}
          />
        </div>
      </section>
    )
  }

  return (
    <section className="rounded-3xl bg-card p-6 soft-shadow" aria-labelledby="plan-heading">
      <h2 id="plan-heading" className="text-base font-semibold">
        خطط الختمة
      </h2>
      {choosing ? (
        <div className="mt-4 flex flex-col gap-2 animate-in fade-in duration-300">
          <p className="text-sm text-muted-foreground">اختر مدة الختمة المناسبة لك</p>
          {PLAN_OPTIONS.map((o) => (
            <button
              key={o.days}
              type="button"
              onClick={() => {
                setKhatmaPlan({ days: o.days, pagesPerDay: Math.ceil(QURAN_TOTAL_PAGES / o.days) })
                setChoosing(false)
              }}
              className="flex items-center justify-between rounded-2xl border px-4 py-3 text-right transition-colors hover:border-primary hover:bg-primary/5"
            >
              <span className="font-medium">{o.label}</span>
              <span className="text-xs text-muted-foreground">
                {`${toArabicDigits(Math.ceil(QURAN_TOTAL_PAGES / o.days))} صفحة / يوم`}
              </span>
            </button>
          ))}
          <button
            type="button"
            onClick={() => setChoosing(false)}
            className="mt-1 py-2 text-sm text-muted-foreground hover:text-foreground"
          >
            إلغاء
          </button>
        </div>
      ) : (
        <div className="flex flex-col items-center py-6 text-center">
          <span className="flex size-16 items-center justify-center rounded-full bg-muted text-primary">
            <Flag className="size-7" strokeWidth={1.6} aria-hidden="true" />
          </span>
          <p className="mt-4 font-medium">لا توجد خطط بعد</p>
          <p className="mt-1 max-w-[240px] text-sm leading-relaxed text-muted-foreground text-pretty">
            أنشئ خطة ختمة تناسب وقتك وسنذكّرك بوردك اليومي
          </p>
          <button
            type="button"
            onClick={() => setChoosing(true)}
            className="mt-5 flex items-center gap-2 rounded-2xl bg-primary px-5 py-3 text-sm font-semibold text-primary-foreground transition-transform active:scale-[0.98]"
          >
            <Plus className="size-4" aria-hidden="true" />
            إنشاء أول خطة
          </button>
        </div>
      )}
    </section>
  )
}
