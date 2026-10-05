'use client'

import { BookOpen, CalendarDays, Flame, HandHeart, MoonStar, Star } from 'lucide-react'
import { useAppState } from '../app-state'
import { ProgressRing } from '../progress-ring'
import { JOURNEY_GOAL, POINTS, toArabicDigits } from '@/lib/rafiq-data'

const BREAKDOWN = [
  { label: 'صلاة الفريضة', note: 'لكل صلاة في وقتها', points: POINTS.fard, Icon: MoonStar, tone: 'bg-mint text-mint-foreground' },
  { label: 'صلاة السنة', note: 'لكل سنة راتبة', points: POINTS.sunnah, Icon: Star, tone: 'bg-butter text-butter-foreground' },
  { label: 'ورد الأذكار', note: 'عند إتمام مجموعة كاملة', points: POINTS.adhkarSession, Icon: HandHeart, tone: 'bg-lilac text-lilac-foreground' },
  { label: 'قراءة القرآن', note: 'لكل صفحة تقرؤها', points: POINTS.quranPage, Icon: BookOpen, tone: 'bg-sky text-sky-foreground' },
]

export function ProgressScreen() {
  const { points, streak } = useAppState()

  return (
    <div className="flex flex-col gap-5 px-4 pt-2">
      <section className="islamic-pattern rounded-3xl bg-hero p-6 text-hero-foreground soft-shadow">
        <h2 className="text-center text-lg font-semibold">رحلتك الإيمانية</h2>
        <p className="mt-1 text-center text-xs text-hero-foreground/70">كل عمل صالح يقرّبك خطوة</p>
        <div className="mt-5 flex justify-center">
          <ProgressRing value={points / JOURNEY_GOAL} size={176} stroke={12} label="النقاط المكتسبة">
            <span className="text-5xl font-bold leading-none">{toArabicDigits(points)}</span>
            <span className="mt-2 text-xs text-hero-foreground/70">{`من ${toArabicDigits(JOURNEY_GOAL)} نقطة`}</span>
          </ProgressRing>
        </div>
        <p className="mt-4 text-center text-sm text-hero-foreground/80">
          {points >= JOURNEY_GOAL
            ? 'ما شاء الله! بلغت هدف اليوم'
            : `${toArabicDigits(JOURNEY_GOAL - points)} نقطة للوصول إلى هدفك`}
        </p>
      </section>

      <div className="grid grid-cols-2 gap-3">
        <MetricCard label="أيام النشاط" value={streak.activeDays} Icon={CalendarDays} tone="bg-sky text-sky-foreground" />
        <MetricCard label="السلسلة الحالية" value={streak.current} Icon={Flame} tone="bg-peach text-peach-foreground" />
      </div>

      <section className="rounded-3xl bg-card p-5 soft-shadow" aria-labelledby="points-heading">
        <h2 id="points-heading" className="text-base font-semibold">
          كيف تُحتسب النقاط؟
        </h2>
        <ul className="mt-3 flex flex-col divide-y">
          {BREAKDOWN.map(({ label, note, points: p, Icon, tone }) => (
            <li key={label} className="flex items-center gap-3 py-3">
              <span className={`flex size-10 items-center justify-center rounded-xl ${tone}`}>
                <Icon className="size-5" aria-hidden="true" />
              </span>
              <span className="flex-1">
                <span className="block text-sm font-medium">{label}</span>
                <span className="block text-xs text-muted-foreground">{note}</span>
              </span>
              <span className="text-base font-bold text-primary">{`+${toArabicDigits(p)}`}</span>
            </li>
          ))}
        </ul>
      </section>
    </div>
  )
}

function MetricCard({
  label,
  value,
  Icon,
  tone,
}: {
  label: string
  value: number
  Icon: typeof Flame
  tone: string
}) {
  return (
    <div className="rounded-3xl bg-card p-4 soft-shadow">
      <span className={`flex size-10 items-center justify-center rounded-xl ${tone}`}>
        <Icon className="size-5" aria-hidden="true" />
      </span>
      <p className="mt-3 text-3xl font-bold">{toArabicDigits(value)}</p>
      <p className="text-xs text-muted-foreground">{label}</p>
    </div>
  )
}
