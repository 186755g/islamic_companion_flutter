import { BookOpenText, ChevronLeft, HeartHandshake, Landmark, Lightbulb, Scale, Users } from 'lucide-react'
import { toArabicDigits } from '@/lib/rafiq-data'

const CATEGORIES = [
  {
    title: 'أحاديث الأخلاق والمعاملات',
    description: 'مختارات نبوية في حسن الخلق والصدق والأمانة',
    count: 120,
    Icon: HeartHandshake,
    tone: 'bg-peach text-peach-foreground',
  },
  {
    title: 'قصص الأنبياء والصحابة',
    description: 'سير ملهمة من حياة الأنبياء وأصحاب النبي ﷺ',
    count: 48,
    Icon: Users,
    tone: 'bg-sky text-sky-foreground',
  },
  {
    title: 'السيرة النبوية',
    description: 'محطات من حياة النبي ﷺ منذ المولد حتى الوفاة',
    count: 36,
    Icon: Landmark,
    tone: 'bg-butter text-butter-foreground',
  },
  {
    title: 'فقه العبادات',
    description: 'أحكام الطهارة والصلاة والصيام بأسلوب ميسّر',
    count: 64,
    Icon: Scale,
    tone: 'bg-lilac text-lilac-foreground',
  },
  {
    title: 'الأدعية المأثورة',
    description: 'أدعية من القرآن والسنة لكل حال ومناسبة',
    count: 85,
    Icon: BookOpenText,
    tone: 'bg-mint text-mint-foreground',
  },
]

export function LibraryScreen() {
  return (
    <div className="flex flex-col gap-5 px-4 pt-2">
      <section className="islamic-pattern rounded-3xl bg-hero p-6 text-hero-foreground soft-shadow">
        <p className="text-xs font-medium text-gold">المكتبة</p>
        <h2 className="mt-1 text-2xl font-semibold">المكتبة الإسلامية</h2>
        <p className="mt-2 text-sm leading-relaxed text-hero-foreground/75 text-pretty">
          محتوى موثوق ينمّي معرفتك ويقرّبك من دينك، صفحة بعد صفحة.
        </p>
      </section>

      <ul className="flex flex-col gap-3">
        {CATEGORIES.map(({ title, description, count, Icon, tone }) => (
          <li key={title}>
            <button
              type="button"
              className="flex w-full items-center gap-4 rounded-3xl bg-card p-4 text-right soft-shadow transition-transform active:scale-[0.99]"
            >
              <span className={`flex size-12 shrink-0 items-center justify-center rounded-2xl ${tone}`}>
                <Icon className="size-6" aria-hidden="true" />
              </span>
              <span className="flex-1">
                <span className="block text-sm font-semibold">{title}</span>
                <span className="mt-0.5 block text-xs leading-relaxed text-muted-foreground">{description}</span>
                <span className="mt-1 block text-[11px] font-medium text-primary">{`${toArabicDigits(count)} مادة`}</span>
              </span>
              <ChevronLeft className="size-5 text-muted-foreground" aria-hidden="true" />
            </button>
          </li>
        ))}
      </ul>

      <aside className="flex gap-3 rounded-3xl border border-dashed border-gold/50 bg-accent p-4">
        <Lightbulb className="mt-0.5 size-5 shrink-0 text-gold" aria-hidden="true" />
        <div>
          <p className="text-sm font-semibold text-accent-foreground">تأمّل يومي</p>
          <p className="mt-1 text-xs leading-relaxed text-muted-foreground text-pretty">
            {'خصّص عشر دقائق يوميًا للقراءة؛ فـ"أحبّ الأعمال إلى الله أدومها وإن قلّ".'}
          </p>
        </div>
      </aside>
    </div>
  )
}
