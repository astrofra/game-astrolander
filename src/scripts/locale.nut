//	Locale
//	locale.nut

g_locales		<-
[
	{
		ISO2 = "US"
		name = "English"

		font = {	main_font_name = "banksb20caps", hud_font_name = "aerial"	}

		font_norm =
		{
			main_font_name =	{ size = 1.0 tracking = 0.0 leading = 0.0 }
			hud_font_name =		{ size = 1.0 tracking = 0.0 leading = 0.0 }
		}
	},

	{
		ISO2 = "FR"
		name = "Français"

		font = {	main_font_name = "yanone_kaffeesatz", hud_font_name = "aerial"	}

		font_norm =
		{
			main_font_name =	{ size = 1.0 tracking = 0.0 leading = 0.0 }
			hud_font_name =		{ size = 1.0 tracking = 0.0 leading = 0.0 }
		}
	},

	{
		ISO2 = "ES"
		name = "Español"

		font = {	main_font_name = "yanone_kaffeesatz", hud_font_name = "aerial"	}

		font_norm =
		{
			main_font_name =	{ size = 1.0 tracking = 0.0 leading = 0.0 }
			hud_font_name =		{ size = 1.0 tracking = 0.0 leading = 0.0 }
		}
	},

	{
		ISO2 = "IT"
		name = "Italiano"

		font = {	main_font_name = "yanone_kaffeesatz", hud_font_name = "aerial"	}

		font_norm =
		{
			main_font_name =	{ size = 1.0 tracking = 0.0 leading = 0.0 }
			hud_font_name =		{ size = 1.0 tracking = 0.0 leading = 0.0 }
		}
	},

	{
		ISO2 = "JP"
		name = "日本語"

		font = {	main_font_name = "tabimyou", hud_font_name = "hw-zen"	}

		font_norm =
		{
			main_font_name =	{ size = 1.0 tracking = 0.0 leading = 0.0 }
			hud_font_name =		{ size = 1.25 tracking = 0.0 leading = 0.0 }
		}
	},
]

function	tr(str, context = "")
{	return str	}

function	SelectLanguageFromSystemSettings()
{
	print("SelectLanguageFromSystemSettings() FIXME")
}

function	LoadLocaleTable()
{
	print("LoadLocaleTable() FIXME")
}