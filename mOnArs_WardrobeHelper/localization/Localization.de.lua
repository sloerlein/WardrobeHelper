if GetLocale() ~= "deDE" then return end

local o = mOnWardrobe
if o.strings == nil then o.strings = {} end
local s = o.strings

s["Refresh Instance"] = "Aktualisiere Instanz"
s["Refresh Items"] = "Aktualisiere Items"
s["Current Instance"] = "Aktuelle Instanz"
s["Click Refresh Info"] = "Klicke auf den %s Button oben um die Intanzen zu laden."
s["Missing Items"] = "Fehlende Items"
s["Hide List Option"] = "Verberge Liste wenn Instanz geöffnet wird."
s["Refresh Confirmation"] = "Diese Aktion kann dein Spiel für einige Sekunden einfrieren. Willst du fortfahren?"
s["Open Options"] = "Einstellungen öffnen"
s["Debug"] = "Debug"
s["Debug Info"] = "Diese Einstellungen sind experimentell und können dein Spiel unspielbar machen. Du wurdest gewarnt."
s["Disable Progress"] = "Deaktiviere Fortschritt"
s["Disable Progress Info"] = "Kann das Aktualisieren aller Items beschleunigen."

s["Refreshing"] = "Aktualisiere"
s["Hide Minimap"] = "MiniMap Button ausblenden"

s["Disable Confirmation"] = "Deaktiviere Aktualisierungsbestätigung"
s["You're beautiful"] = "Du siehst heute wunderbar aus!"
s["Happy Sunday"] = "Fröhlichen Sonntag!"
s["Other Sources"] = "Andere Quellen"
s["Sources"] = "Quellen"
