---
name: react-nextjs-typescript
description: Modern React, Next.js App Router, and TypeScript architecture guidelines, component patterns, and state management.
---

# React, Next.js & TypeScript Engineering Skill

## 1. Modern React Architecture (v18+)

### Component Design & Composition
- **Compound Components Pattern**: Group related components with shared implicit state (e.g. `Tabs`, `Tabs.List`, `Tabs.Trigger`, `Tabs.Content`).
- **Composition over Prop Drilling**: Pass child components (`children` prop) or slots rather than drilling props down multiple hierarchy layers.
- **Custom Hooks for Logic Isolation**: Extract state transitions, side effects, and API bindings into custom hooks (`useUser`, `useDebounce`, `useLocalStorage`). Keep UI components purely presentational.

### Performance & State Flow
- Prefer local component state (`useState`) or contextual state (`useContext`) for UI-only state.
- Use dedicated caching libraries (TanStack Query / SWR) or React Server Components for server data.
- Apply `useMemo` and `useCallback` deliberately for expensive computations or referential stability in hook dependencies, avoiding premature optimization.

---

## 2. Next.js (App Router)

### Server vs. Client Boundaries
- **Server Components (RSC) by Default**: Keep components on the server for direct database/API access, reduced client JavaScript bundle size, and instant SEO.
- **Client Components (`"use client"`)**: Use only at leaves of the component tree that require browser APIs, event listeners (`onClick`, `onChange`), or React hooks (`useState`, `useEffect`).
- **Streaming with Suspense**: Wrap asynchronous UI chunks in `<Suspense fallback={<Skeleton />}>` to enable progressive rendering without blocking page transitions.

### Server Actions & Form Mutations
- Define Server Actions (`"use server"`) for mutations.
- Pair with `useActionState` (React 19) or `useFormStatus` for pending feedback.
- Use `useOptimistic` for instant UI updates before server confirmation.
- Invalidate cache accurately using `revalidatePath("/path")` or `revalidateTag("tag")`.

---

## 3. Strict TypeScript Standards

### Type Safety & Modeling
- **Zero Unchecked `any`**: Use `unknown` with runtime type narrowing instead of `any`.
- **Discriminated Unions**: Model states with mutually exclusive variants:
  ```typescript
  type AsyncState<T> =
    | { status: 'idle' }
    | { status: 'loading' }
    | { status: 'success'; data: T }
    | { status: 'error'; error: Error };
  ```
- **Generic Components**: Author reusable, strongly typed UI components:
  ```typescript
  interface TableProps<T> {
    data: T[];
    columns: ColumnDef<T>[];
  }
  ```
- **Runtime Schema Validation**: Validate API boundaries, environment variables, and form inputs using **Zod**:
  ```typescript
  import { z } from 'zod';
  export const UserSchema = z.object({
    id: z.string().uuid(),
    email: z.string().email(),
    role: z.enum(['admin', 'member']),
  });
  export type User = z.infer<typeof UserSchema>;
  ```

---

## 4. UI/UX & Design System Standards (Linear / Raycast Minimalist)

### Aesthetic Foundation: Linear / Raycast over Cyberpunk / Neon
- **Core Principle**: Deliver clean, restrained, high-craft software aesthetics (in the style of Linear, Raycast, and Vercel). **Avoid cyberpunky, high-saturation, or aggressive neon glowing looks.**
- **Palette & Dark Mode Surfaces**:
  - Ground background in deep matte charcoal/zinc (`#0c0d0e` to `#0f1013`) rather than saturated navy or electric blue.
  - Card & panel surfaces: Flat or subtly elevated matte containers (`#151619` to `#18191c` or `zinc-900/60`) with crisp hairline borders (`border-zinc-800/80` or `border-white/[0.07]`).
  - Hover states: Gentle luminance increase (`hover:border-zinc-700 hover:bg-zinc-800/40`), never neon outlines.

### Badges, Pills & Semantic Highlights
- **Matte Pastel Tags**: Use low-opacity fills (10% background, 20% border) with legible, low-saturation text:
  - Feature / Primary: `bg-sky-500/10 text-sky-300 border-sky-500/20`
  - Bug / Danger / High Risk: `bg-rose-500/10 text-rose-300 border-rose-500/20`
  - Performance / Warning: `bg-amber-500/10 text-amber-300 border-amber-500/20`
  - Debt / Neutral: `bg-zinc-500/10 text-zinc-300 border-zinc-500/20`
  - Security: `bg-violet-500/10 text-violet-300 border-violet-500/20`
  - Success / Low Risk: `bg-emerald-500/10 text-emerald-400 border-emerald-500/20`
- **Zero Neon Box-Shadow Glows**: Never use heavy, colored `box-shadow` glows (e.g. `shadow-glow-emerald`, `shadow-glow-rose`). Rely on hairline borders and subtle ambient drop shadows.

### Micro-Interactions & Typography
- **Quiet Status Indicators**: Use crisp, small indicator dots (e.g. a 6px emerald dot with a gentle ping animation) instead of pulsating neon badges.
- **Monospace Tags**: Format issue keys, hashes, IDs, and timestamps with clean monospace font (`font-mono text-xs text-zinc-300`).
- **Restrained Motion**: Use fast, subtle transitions (`duration-150 ease-out`). Highlight incoming items with brief border highlights rather than bright glowing flashes.
- **Code & Raw Data Display**: Use muted dark backgrounds (`bg-zinc-950 border-zinc-800`) with subtle syntax highlighting for technical diffs and JSON payloads.
