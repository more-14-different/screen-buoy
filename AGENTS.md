# Repository Guidelines

## Project Structure & Module Organization

Screen Buoy is a Tauri 2 desktop app with a React/Vite settings UI and a Rust backend. Frontend code lives in `src/`: `App.tsx`, `components/settings/`, `hooks/`, `locales/`, `styles/`, and `types/`. Native logic lives in `src-tauri/src/`; OS-specific files use `_win.rs` and `_macos.rs` suffixes. Icons are in `src-tauri/icons/`, app configuration is in `Tauri.toml` plus `config*.toml`, and demo media is in `docs/`.

## Build, Test, and Development Commands

- `npm install`: install frontend and Tauri CLI dependencies.
- `npm run dev`: run the Vite frontend only.
- `npm run tauri:dev`: run the full desktop app in development mode.
- `.\run-screen-buoy.ps1`: rebuild and restart the executable.
- `npm run build`: type-check with `tsc` and build the frontend bundle.
- `npm run tauri build`: build a distributable Tauri app.
- `cd src-tauri; cargo build`: compile the Rust backend directly.
- `cd src-tauri; cargo test`: run Rust tests when present.

## Coding Style & Naming Conventions

Use TypeScript/React functional components and PascalCase component files, for example `Settings.tsx`. Hooks should use `use*` camelCase names. Keep locale keys synchronized between `src/locales/en.json` and `src/locales/zh.json`. Rust modules use snake_case file and module names; keep OS-specific behavior in platform files such as `hook_windows.rs` and `mouse_macos.rs`. Run `npm run build` before frontend submissions and `cargo fmt` before Rust submissions.

## Testing Guidelines

There is no committed JavaScript test runner configuration at present. For frontend changes, use `npm run build` as the minimum validation. For Rust changes, run `cargo test` from `src-tauri`; add focused unit tests near deterministic logic. For global hooks, accessibility, windowing, or input behavior, also verify manually on the affected platform because behavior depends on OS permissions and native APIs.

## Commit & Pull Request Guidelines

Recent history uses short Conventional Commit-style subjects such as `feat: add macOS support`, `fix: Windows build - fix module path for hook_windows.rs`, and `chore: update README...`. Prefer `feat:`, `fix:`, or `chore:` with an imperative summary. Pull requests should describe the change, list validation commands, mention affected platforms, link issues when applicable, and include screenshots or GIFs for UI changes.

## Security & Configuration Tips

Do not commit local secrets or machine-specific settings. Treat `src-tauri/config.toml` and `config_macos.toml` as user-facing examples; document new options in both README files when behavior changes. macOS changes may require Accessibility and Input Monitoring permissions, and Windows changes may touch UI Automation or global hook behavior, so call out permission impacts in reviews.
