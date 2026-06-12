import type { Metadata, Viewport } from "next";
import { Barlow_Semi_Condensed, Inter, JetBrains_Mono } from "next/font/google";
import type { ReactNode } from "react";

import { AppProviders } from "@/components/providers/app-providers";
import "./globals.css";

const sansFont = Inter({
  subsets: ["latin"],
  variable: "--font-sans",
  axes: ["opsz"],
});

const displayFont = Barlow_Semi_Condensed({
  subsets: ["latin"],
  variable: "--font-display",
  weight: ["500", "600", "700", "800"],
});

const monoFont = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
});

export const metadata: Metadata = {
  title: "LiftIQ",
  description: "A quiet training journal. Lift with intention; let the numbers speak.",
  manifest: "/manifest.webmanifest",
};

export const viewport: Viewport = {
  themeColor: "#0A0B12",
};

// Applies the stored theme before first paint so light-theme users don't get
// a dark flash (the provider takes over after hydration).
const themeInitScript = `(function(){try{var t=localStorage.getItem("liftiq-theme");document.documentElement.dataset.theme=t==="light"||t==="paper"||t==="bone"||t==="warm-lift"||t==="neon-gym"?"light":"dark";}catch(e){}})()`;

export default function RootLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  return (
    <html lang="en" data-theme="dark" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: themeInitScript }} />
      </head>
      <body
        className={`${sansFont.variable} ${displayFont.variable} ${monoFont.variable} antialiased`}
      >
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
