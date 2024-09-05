//	Locale
//	locale.nut

	Include("scripts/locale_en.nut")

g_locale	<-	{

}

//--------------------------------------------
function	SelectLanguageFromSystemSettings()
//--------------------------------------------
{
	local	_lang = SystemGetLocale()
	switch(_lang)
	{
		case "FR":
			g_current_language		=	"fr"
			break
		case "ES":
			g_current_language		=	"es"
			break
		case "IT":
			g_current_language		=	"it"
			break
		case "DE":
			g_current_language		=	"de"
			break
		case "JP":
			g_current_language		=	"jp"
			break
		case "CN":
			g_current_language		=	"cn"
			break
		case "EN":
		default:
			g_current_language		=	"en"
			break
	}
}

function	SwitchToNextLanguage()
{
		print("SwitchToNextLanguage()")
		local	locale_fname

		//	look for the current language index
		local	lang_index = g_supported_languages.find(g_current_language)
		if (lang_index == null)
			return
	
		//	increment this index
		lang_index++
		if (lang_index >= g_supported_languages.len())
			lang_index = 0

		//	select new language
		g_current_language = g_supported_languages[lang_index]

		//	reload locale table
		locale_fname = "scripts/locale_" + g_current_language + ".nut"
		if (FileExists(locale_fname))
		{
			Include(locale_fname)
			LoadLocaleTable()
		}
		else
			print("SwitchToNextLanguage() : cannot find '" + locale_fname + "'.")
}

function	LoadLocaleTable()
{
	local	_root = getroottable()
	print("LoadLocaleTable() : g_current_language = " + g_current_language)

	if (!(("g_locale_" + g_current_language) in _root))
	{
		local	locale_fname = "scripts/locale_" + g_current_language + ".nut"
		if (FileExists(locale_fname))
		{
			Include(locale_fname)
			LoadLocaleTable()
		}
	}

//	if (("g_locale_" + g_current_language) in _root)
	{
		g_locale = _root["g_locale_" + g_current_language]

		if (g_current_language != "en")
		{
			foreach(entry_key, entry in g_locale_en)
			{
				if (!(entry_key in g_locale))
					g_locale.rawset(entry_key, entry)
			}
		}
	
		//	UI font
		if ("main_font_name" in g_locale)
			g_main_font_name = g_locale.main_font_name
		else
			g_main_font_name = g_default_font_name

		//	HUD font
		if ("hud_font_name" in g_locale)
			g_hud_font_name = g_locale.hud_font_name
		else
			g_hud_font_name = g_default_hud_font_name

		if ("hud_font_size" in g_locale)
			g_hud_font_size = g_locale.hud_font_size
		else
			g_hud_font_size = 1.0
	}
}