//	Locale
//	locale.nut

	Include("scripts/locale_en.nut")
	Include("scripts/locale_fr.nut")
	Include("scripts/locale_jp.nut")

g_locale	<-	{

}

function	LoadLocaleTable()
{
	switch(g_current_language)
	{
		case	"fr":
			g_locale = g_locale_fr
			break
		case	"jp":
			g_locale = g_locale_jp
			break
		case	"en":
		default		:
			g_locale = g_locale_en
			break
	}

	if (g_current_language != "en")
	{
		foreach(entry_key, entry in g_locale_en)
		{
			if (!(entry in g_locale))
				g_locale.rawset(entry_key, entry)
		}
	}

	if ("main_font_name" in g_locale)
		g_main_font_name = g_locale.main_font_name
	else
		g_main_font_name = g_default_font_name
}