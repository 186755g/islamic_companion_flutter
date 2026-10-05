'use client'

import { Check, CloudSun, Flame, Quote, Sparkles, Trophy, CalendarDays } from 'lucide-react'
import { useAppState } from '../app-state'
import { ProgressRing } from '../progress-ring'
import { PRAYERS, SUNNAH_PRAYERS, TONE_CLASSES, toArabicDigits } from '@/lib/rafiq-data'

const NEXT_PRAYER_ID = 'asr'
const WEEK = [
  { day: 'سبت', value: 5 },
  { day: 'أحد', value: 4 },
  { day: 'إثنين', value: 5 },
  { day: 'ثلاثاء', value: 3 },
  { day: 'أربعاء', value: 5 },
  { day: 'خميس', value: 4 },
]

export function PrayerScreen() {
  return (
    <div className="flex flex-col gap-5 px-4 pt-2">
      <HadithCard />
      <HeroCard />
      <NextPrayerCard />
      <PrayerTimesRow />
      <PrayerTracker />
      <WeeklyCard />
    </div>
  )
}

function HeroCard() {
  const { fardDone, streak } = useAppState()
  const done = fardDone.size

  return (
    <section className="islamic-pattern relative overflow-hidden rounded-3xl bg-hero p-5 text-hero-foreground soft-shadow">
      <div className="flex items-center gap-5">
        <ProgressRing value={done / 5} size={104} stroke={9} label="الصلوات المكتملة اليوم">
          <span className="text-3xl font-bold leading-none">{toArabicDigits(done)}</span>
          <span className="mt-1 text-xs text-hero-foreground/70">{`من ${toArabicDigits(5)}`}</span>
        </ProgressRing>
        <div className="flex-1">
          <p className="text-sm text-hero-foreground/70">الأحد، ٢٣ ذو القعدة ١٤٤٧</p>
          <h2 className="mt-1 text-xl font-semibold text-balance">
            {done === 5 ? 'أتممت صلوات اليوم' : `أكملت ${toArabicDigits(done)} من ${toArabicDigits(5)} صلوات`}
          </h2>
          <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-hero-foreground/15">
            <div
              className="h-full rounded-full bg-gold transition-all duration-700"
              style={{ width: `${(done / 5) * 100}%` }}
            />
          </div>
        </div>
      </div>

      <div className="mt-5 rounded-2xl bg-hero-foreground/[0.07] p-3">
        <div className="mb-2 flex items-center gap-2 text-sm font-medium">
          <Flame className="size-4 text-gold" aria-hidden="true" />
          سلسلة المواظبة
        </div>
        <dl className="grid grid-cols-3 divide-x divide-hero-foreground/10 text-center">
          <StreakStat label="الحالية" value={streak.current} />
          <StreakStat label="الأطول" value={streak.longest} />
          <StreakStat label="أيام النشاط" value={streak.activeDays} />
        </dl>
      </div>
    </section>
  )
}

function StreakStat({ label, value }: { label: string; value: number }) {
  return (
    <div className="flex flex-col-reverse gap-0.5">
      <dt className="text-[11px] text-hero-foreground/65">{label}</dt>
      <dd className="text-lg font-bold">{toArabicDigits(value)}</dd>
    </div>
  )
}

function NextPrayerCard() {
  const next = PRAYERS.find((p) => p.id === NEXT_PRAYER_ID)!
  return (
    <section
      aria-label="الصلاة القادمة"
      className="flex items-center gap-4 rounded-3xl border border-gold/40 bg-card p-4 soft-shadow"
    >
      <div className="flex size-14 items-center justify-center rounded-2xl bg-gold-soft text-accent-foreground">
        <CloudSun className="size-7" aria-hidden="true" />
      </div>
      <div className="flex-1">
        <p className="text-xs text-muted-foreground">الصلاة القادمة</p>
        <p className="text-lg font-semibold text-foreground">{`صلاة ${next.name}`}</p>
        <p className="text-xs text-muted-foreground">متبقي ٣ س و ١٢ د</p>
      </div>
      <div className="text-left">
        <p className="text-2xl font-bold text-primary tabular-nums">{toArabicDigits(next.time)}</p>
        <p className="text-xs text-muted-foreground">مساءً · ٣٢°</p>
      </div>
    </section>
  )
}

function PrayerTimesRow() {
  return (
    <section aria-labelledby="times-heading">
      <h2 id="times-heading" className="mb-3 text-base font-semibold">
        مواقيت اليوم
      </h2>
      <ul className="no-scrollbar -mx-4 flex gap-3 overflow-x-auto px-4 py-1.5">
        {PRAYERS.map((p) => {
          const isNext = p.id === NEXT_PRAYER_ID
          return (
            <li
              key={p.id}
              className={`flex min-w-[84px] flex-col items-center gap-1 rounded-2xl px-3 py-3 ${TONE_CLASSES[p.tone]} ${
                isNext ? 'ring-2 ring-gold ring-offset-2 ring-offset-background' : ''
              }`}
            >
              <span className="text-sm font-medium">{p.name}</span>
              <span className="text-lg font-bold tabular-nums">{toArabicDigits(p.time)}</span>
              <span className="text-[11px] opacity-75">{p.period === 'ص' ? 'صباحًا' : 'مساءً'}</span>
            </li>
          )
        })}
      </ul>
    </section>
  )
}

function CheckRow({
  checked,
  onToggle,
  title,
  subtitle,
  points,
}: {
  checked: boolean
  onToggle: () => void
  title: string
  subtitle: string
  points: number
}) {
  return (
    <li>
      <button
        type="button"
        role="checkbox"
        aria-checked={checked}
        onClick={onToggle}
        className="flex w-full items-center gap-3 rounded-2xl px-3 py-3 text-right transition-colors hover:bg-muted/60"
      >
        <span
          className={`flex size-6 shrink-0 items-center justify-center rounded-lg border-2 transition-all ${
            checked ? 'border-primary bg-primary text-primary-foreground' : 'border-input bg-card'
          }`}
        >
          {checked && <Check className="size-4" strokeWidth={3} aria-hidden="true" />}
        </span>
        <span className="flex-1">
          <span className={`block text-sm font-medium ${checked ? 'text-muted-foreground line-through' : ''}`}>
            {title}
          </span>
          <span className="block text-xs text-muted-foreground">{subtitle}</span>
        </span>
        <span className="rounded-full bg-gold-soft px-2 py-0.5 text-[11px] font-semibold text-accent-foreground">
          {`+${toArabicDigits(points)}`}
        </span>
      </button>
    </li>
  )
}

function PrayerTracker() {
  const { fardDone, sunnahDone, toggleFard, toggleSunnah } = useAppState()

  return (
    <section className="rounded-3xl bg-card p-2 soft-shadow" aria-labelledby="tracker-heading">
      <div className="flex items-center justify-between px-3 pt-3 pb-1">
        <h2 id="tracker-heading" className="text-base font-semibold">
          متابعة الصلوات
        </h2>
        <span className="text-xs text-muted-foreground">{`${toArabicDigits(fardDone.size)}/${toArabicDigits(5)} فرائض`}</span>
      </div>
      <p className="px-3 pt-2 text-xs font-medium text-primary">الفرائض</p>
      <ul>
        {PRAYERS.map((p) => (
          <CheckRow
            key={p.id}
            checked={fardDone.has(p.id)}
            onToggle={() => toggleFard(p.id)}
            title={`صلاة ${p.name}`}
            subtitle={`${toArabicDigits(p.time)} ${p.period === 'ص' ? 'صباحًا' : 'مساءً'}`}
            points={10}
          />
        ))}
      </ul>
      <div className="mx-3 my-1 border-t border-dashed" />
      <p className="px-3 pt-2 text-xs font-medium text-primary">السنن الرواتب</p>
      <ul>
        {SUNNAH_PRAYERS.map((s) => (
          <CheckRow
            key={s.id}
            checked={sunnahDone.has(s.id)}
            onToggle={() => toggleSunnah(s.id)}
            title={s.name}
            subtitle={s.rakahs === 1 ? 'ركعة واحدة' : `${toArabicDigits(s.rakahs)} ركعات`}
            points={5}
          />
        ))}
      </ul>
    </section>
  )
}

function WeeklyCard() {
  const { fardDone } = useAppState()
  const days = [...WEEK, { day: 'اليوم', value: fardDone.size }]
  const total = days.reduce((sum, d) => sum + d.value, 0)

  return (
    <section className="rounded-3xl bg-card p-4 soft-shadow" aria-labelledby="week-heading">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="flex size-9 items-center justify-center rounded-xl bg-mint text-mint-foreground">
            <Trophy className="size-5" aria-hidden="true" />
          </span>
          <div>
            <h2 id="week-heading" className="text-sm font-semibold">
              إنجاز الأسبوع
            </h2>
            <p className="text-xs text-muted-foreground">{`${toArabicDigits(total)} من ${toArabicDigits(35)} صلاة`}</p>
          </div>
        </div>
        <span className="text-2xl font-bold text-primary">{`${toArabicDigits(Math.round((total / 35) * 100))}٪`}</span>
      </div>
      <div className="mt-4 flex items-end justify-between gap-2" aria-hidden="true">
        {days.map((d) => (
          <div key={d.day} className="flex flex-1 flex-col items-center gap-1.5">
            <div className="flex h-16 w-full items-end overflow-hidden rounded-lg bg-muted">
              <div
                className={`w-full rounded-lg transition-all duration-500 ${d.day === 'اليوم' ? 'bg-gold' : 'bg-primary'}`}
                style={{ height: `${(d.value / 5) * 100}%` }}
              />
            </div>
            <span className="text-[10px] text-muted-foreground">{d.day}</span>
          </div>
        ))}
      </div>
    </section>
  )
}

function HadithCard() {
  return (
    <section
      className="relative overflow-hidden rounded-3xl border border-gold/30 bg-accent p-5"
      aria-labelledby="hadith-heading"
    >
      <div className="flex items-center gap-2 text-accent-foreground">
        <Sparkles className="size-4" aria-hidden="true" />
        <h2 id="hadith-heading" className="text-sm font-semibold">
          حديث اليوم
        </h2>
        <CalendarDays className="mr-auto size-4 opacity-60" aria-hidden="true" />
      </div>
      <Quote className="mt-3 size-6 text-gold" aria-hidden="true" />
      <blockquote className="mt-1 font-quran text-2xl leading-[2.1] text-foreground text-pretty">
        إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى
      </blockquote>
      <p className="mt-2 text-xs text-muted-foreground">متفق عليه — رواه البخاري ومسلم</p>
    </section>
  )
}
