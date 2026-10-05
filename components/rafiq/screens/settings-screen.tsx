'use client'

import { useState } from 'react'
import {
  Bell,
  Check,
  ChevronDown,
  Info,
  LocateFixed,
  Mail,
  MapPin,
  MessageCircle,
  Moon,
  Palette,
  Search,
  Type,
  Volume2,
} from 'lucide-react'
import { useAppState } from '../app-state'
import { FONT_SIZES, toArabicDigits } from '@/lib/rafiq-data'

const COUNTRIES: Record<string, string[]> = {
  مصر: ['القاهرة', 'الجيزة', 'الإسكندرية', 'المنصورة', 'أسيوط'],
  السعودية: ['مكة المكرمة', 'المدينة المنورة', 'الرياض', 'جدة', 'الدمام'],
  الإمارات: ['أبوظبي', 'دبي', 'الشارقة'],
  المغرب: ['الرباط', 'الدار البيضاء', 'فاس', 'مراكش'],
}

const RECITERS = ['مشاري العفاسي', 'عبد الباسط عبد الصمد', 'محمد رفعت', 'الحرم المكي', 'الحرم المدني']

const ANIMATIONS = ['انسيابي', 'تلاشي', 'انزلاق', 'بدون حركة']

const SECTION_KEYWORDS = {
  location: 'الموقع الحساب الدولة المحافظة gps تحديد',
  sound: 'الصوت الإشعارات الأذان مستوى المؤذن الفجر',
  display: 'العرض الخط الحجم الحركة البطاقات',
  appearance: 'المظهر الوضع الداكن الليلي',
  about: 'المطور حول الإصدار تواصل',
}

export function SettingsScreen() {
  const [query, setQuery] = useState('')
  const q = query.trim()
  const visible = (key: keyof typeof SECTION_KEYWORDS) => !q || SECTION_KEYWORDS[key].includes(q)
  const anyVisible = (Object.keys(SECTION_KEYWORDS) as (keyof typeof SECTION_KEYWORDS)[]).some(visible)

  return (
    <div className="flex flex-col gap-5 px-4 pt-2 animate-in fade-in slide-in-from-bottom-2 duration-300">
      <label className="relative block">
        <span className="sr-only">ابحث في الإعدادات</span>
        <Search
          className="pointer-events-none absolute top-1/2 right-4 size-4 -translate-y-1/2 text-muted-foreground"
          aria-hidden="true"
        />
        <input
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="ابحث في الإعدادات..."
          className="w-full rounded-2xl border bg-card py-3 pr-11 pl-4 text-sm outline-none placeholder:text-muted-foreground focus:border-primary focus:ring-2 focus:ring-primary/15"
        />
      </label>

      {visible('location') && <LocationSection />}
      {visible('sound') && <SoundSection />}
      {visible('display') && <DisplaySection />}
      {visible('appearance') && <AppearanceSection />}
      {visible('about') && <CreditsCard />}
      {!anyVisible && (
        <p className="py-10 text-center text-sm text-muted-foreground">{`لا توجد نتائج لـ "${q}"`}</p>
      )}
    </div>
  )
}

function Section({
  title,
  Icon,
  children,
}: {
  title: string
  Icon: typeof Bell
  children: React.ReactNode
}) {
  return (
    <section className="flex flex-col gap-2">
      <h2 className="flex items-center gap-2 px-1 text-xs font-semibold text-muted-foreground">
        <Icon className="size-3.5" aria-hidden="true" />
        {title}
      </h2>
      <div className="rounded-3xl bg-card p-4 soft-shadow">{children}</div>
    </section>
  )
}

function Toggle({
  checked,
  onChange,
  label,
}: {
  checked: boolean
  onChange: (v: boolean) => void
  label: string
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      onClick={() => onChange(!checked)}
      className={`relative h-7 w-12 shrink-0 rounded-full transition-colors ${checked ? 'bg-primary' : 'bg-input'}`}
    >
      <span
        className={`absolute top-1 size-5 rounded-full bg-white shadow transition-all duration-300 ${
          checked ? 'right-6' : 'right-1'
        }`}
      />
    </button>
  )
}

function SelectField({
  label,
  value,
  options,
  onChange,
}: {
  label: string
  value: string
  options: string[]
  onChange: (v: string) => void
}) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="text-xs text-muted-foreground">{label}</span>
      <span className="relative">
        <select
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="w-full appearance-none rounded-xl border bg-background py-2.5 pr-3 pl-9 text-sm outline-none focus:border-primary"
        >
          {options.map((o) => (
            <option key={o} value={o}>
              {o}
            </option>
          ))}
        </select>
        <ChevronDown
          className="pointer-events-none absolute top-1/2 left-3 size-4 -translate-y-1/2 text-muted-foreground"
          aria-hidden="true"
        />
      </span>
    </label>
  )
}

function LocationSection() {
  const [country, setCountry] = useState('مصر')
  const [city, setCity] = useState('القاهرة')
  const [detecting, setDetecting] = useState(false)
  const [detected, setDetected] = useState(false)

  const detect = () => {
    setDetecting(true)
    setTimeout(() => {
      setCountry('مصر')
      setCity('القاهرة')
      setDetecting(false)
      setDetected(true)
    }, 900)
  }

  return (
    <Section title="الموقع وطريقة الحساب" Icon={MapPin}>
      <button
        type="button"
        onClick={detect}
        disabled={detecting}
        className="flex w-full items-center justify-center gap-2 rounded-2xl bg-primary/10 py-3 text-sm font-semibold text-primary transition-colors hover:bg-primary/15 disabled:opacity-70"
      >
        {detected && !detecting ? (
          <Check className="size-4" aria-hidden="true" />
        ) : (
          <LocateFixed className={`size-4 ${detecting ? 'animate-spin' : ''}`} aria-hidden="true" />
        )}
        {detecting ? 'جارٍ تحديد موقعك...' : detected ? 'تم التحديد: القاهرة، مصر' : 'تحديد الموقع تلقائيًا'}
      </button>
      <div className="mt-4 grid grid-cols-2 gap-3">
        <SelectField
          label="الدولة"
          value={country}
          options={Object.keys(COUNTRIES)}
          onChange={(v) => {
            setCountry(v)
            setCity(COUNTRIES[v][0])
          }}
        />
        <SelectField label="المحافظة" value={city} options={COUNTRIES[country]} onChange={setCity} />
      </div>
      <p className="mt-3 text-[11px] text-muted-foreground">طريقة الحساب: الهيئة المصرية العامة للمساحة</p>
    </Section>
  )
}

function ReciterAccordion({ title }: { title: string }) {
  const [open, setOpen] = useState(false)
  const [reciter, setReciter] = useState(RECITERS[0])

  return (
    <div className="rounded-2xl border">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        className="flex w-full items-center justify-between px-4 py-3 text-right"
      >
        <span>
          <span className="block text-sm font-medium">{title}</span>
          <span className="block text-xs text-muted-foreground">{reciter}</span>
        </span>
        <ChevronDown
          className={`size-4 text-muted-foreground transition-transform ${open ? 'rotate-180' : ''}`}
          aria-hidden="true"
        />
      </button>
      {open && (
        <ul role="radiogroup" aria-label={title} className="border-t px-2 py-2 animate-in fade-in duration-200">
          {RECITERS.map((r) => (
            <li key={r}>
              <button
                type="button"
                role="radio"
                aria-checked={r === reciter}
                onClick={() => setReciter(r)}
                className="flex w-full items-center justify-between rounded-xl px-3 py-2.5 text-sm hover:bg-muted"
              >
                {r}
                <span
                  className={`flex size-5 items-center justify-center rounded-full border-2 ${
                    r === reciter ? 'border-primary' : 'border-input'
                  }`}
                >
                  {r === reciter && <span className="size-2.5 rounded-full bg-primary" />}
                </span>
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}

function SoundSection() {
  const [adhan, setAdhan] = useState(true)
  const [volume, setVolume] = useState(70)

  return (
    <Section title="الصوت والإشعارات" Icon={Bell}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium">صوت الأذان</p>
          <p className="text-xs text-muted-foreground">تشغيل الأذان عند دخول الوقت</p>
        </div>
        <Toggle checked={adhan} onChange={setAdhan} label="صوت الأذان" />
      </div>
      <div className={`mt-4 transition-opacity ${adhan ? '' : 'pointer-events-none opacity-40'}`}>
        <div className="flex items-center justify-between text-xs">
          <span className="flex items-center gap-1.5 text-muted-foreground">
            <Volume2 className="size-4" aria-hidden="true" />
            مستوى الصوت
          </span>
          <span className="font-semibold text-primary">{`${toArabicDigits(volume)}٪`}</span>
        </div>
        <input
          type="range"
          min={0}
          max={100}
          value={volume}
          onChange={(e) => setVolume(Number(e.target.value))}
          aria-label="مستوى الصوت"
          className="mt-2 w-full accent-primary"
        />
        <div className="mt-4 flex flex-col gap-2">
          <ReciterAccordion title="مؤذن صلاة الفجر" />
          <ReciterAccordion title="مؤذن باقي الصلوات" />
        </div>
      </div>
    </Section>
  )
}

function DisplaySection() {
  const { fontSizeIndex, setFontSizeIndex } = useAppState()
  const [animation, setAnimation] = useState(ANIMATIONS[0])

  return (
    <Section title="العرض والواجهة" Icon={Type}>
      <SelectField label="حركة البطاقات" value={animation} options={ANIMATIONS} onChange={setAnimation} />
      <div className="mt-5">
        <div className="flex items-center justify-between text-xs">
          <span className="text-muted-foreground">حجم الخط</span>
          <span className="font-semibold text-primary">{FONT_SIZES[fontSizeIndex].label}</span>
        </div>
        <input
          type="range"
          min={0}
          max={FONT_SIZES.length - 1}
          step={1}
          value={fontSizeIndex}
          onChange={(e) => setFontSizeIndex(Number(e.target.value))}
          aria-label="حجم الخط"
          aria-valuetext={FONT_SIZES[fontSizeIndex].label}
          className="mt-2 w-full accent-primary"
        />
        <div className="mt-1 flex justify-between text-[10px] text-muted-foreground" aria-hidden="true">
          {FONT_SIZES.map((f) => (
            <span key={f.label}>{f.label}</span>
          ))}
        </div>
        <div className="mt-4 rounded-2xl bg-muted p-4 text-center">
          <p className="text-[10px] text-muted-foreground">معاينة مباشرة</p>
          <p
            className="mt-1 font-quran leading-[2] transition-all"
            style={{ fontSize: 'calc(1.375rem * var(--text-scale, 1))' }}
          >
            سُبْحَانَ اللَّهِ وَبِحَمْدِهِ
          </p>
        </div>
      </div>
    </Section>
  )
}

function AppearanceSection() {
  const { darkMode, setDarkMode } = useAppState()
  return (
    <Section title="المظهر" Icon={Palette}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="flex size-10 items-center justify-center rounded-xl bg-lilac text-lilac-foreground">
            <Moon className="size-5" aria-hidden="true" />
          </span>
          <div>
            <p className="text-sm font-medium">الوضع الداكن</p>
            <p className="text-xs text-muted-foreground">مريح للعين في الليل</p>
          </div>
        </div>
        <Toggle checked={darkMode} onChange={setDarkMode} label="الوضع الداكن" />
      </div>
    </Section>
  )
}

function CreditsCard() {
  return (
    <Section title="حول التطبيق" Icon={Info}>
      <div className="flex items-center gap-3">
        <span className="flex size-12 items-center justify-center rounded-2xl bg-hero font-quran text-xl font-bold text-gold">
          ر
        </span>
        <div className="flex-1">
          <p className="text-sm font-semibold">رفيق المسلم</p>
          <p className="text-xs text-muted-foreground">الإصدار <bdi dir="ltr">٢٫٠٫٠</bdi> · تطوير محمد أحمد</p>
        </div>
      </div>
      <div className="mt-4 grid grid-cols-2 gap-2">
        <a
          href="mailto:"
          className="flex items-center justify-center gap-2 rounded-xl border py-2.5 text-sm font-medium transition-colors hover:bg-muted"
        >
          <Mail className="size-4" aria-hidden="true" />
          البريد
        </a>
        <a
          href="https://wa.me/"
          target="_blank"
          rel="noreferrer"
          className="flex items-center justify-center gap-2 rounded-xl bg-[#25D366]/15 py-2.5 text-sm font-medium text-[#128C4B] transition-colors hover:bg-[#25D366]/25 dark:text-[#5fe39a]"
        >
          <MessageCircle className="size-4" aria-hidden="true" />
          واتساب
        </a>
      </div>
    </Section>
  )
}
