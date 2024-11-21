export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body bgcolor='#b0FFFF'>{children}</body>
    </html>
  );
}
