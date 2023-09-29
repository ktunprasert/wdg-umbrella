%{
  site_name: "/wdg/.one",
  site_description: "A collection of projects by /wdg/ devs",
  date_format: "{WDfull}, {D} {Mshort} {YYYY}",
  base_url: "/",
  author: "Kris Tun",
  author_email: "kris@kristun.dev",
  plugins: [
    {Serum.Plugins.LiveReloader, only: :dev}
  ]
}
