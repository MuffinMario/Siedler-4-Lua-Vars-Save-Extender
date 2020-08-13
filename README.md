# Siedler-4-Lua-Vars-Save-Extender
Siedler 4 stellt beim Speichern des Spiels neun [double-precision floating point](https://de.wikipedia.org/wiki/Doppelte_Genauigkeit) Variablen zur Verfügung, die der Scripter für die Map benutzen kann. In den meisten Fällen, reichen diese aus, alle Sachen, die man im Laufe des Spiels im Überblick behalten muss zu speichern. 

Jedoch gibt es auch Fälle in denen man mehr als neun Sachen speichern muss, in diesem Falle hilft diese Bibliothek weiter.

# Wie funktioniert diese Bibliothek?
Es ist natürlich nicht möglich mehr Zahlen in den Speicherplatz zu tun, ohne das Spiel zu modifizieren. Was wir jedoch haben, ist ein hilfreiches Werkzeug namens Lua. Mittels Stringmanagement und indem wir annehmen, dass wir alle Zahlen unter 1 Millarden ohne floating point rounding darstellen können, machen wir und das zu nutze, indem wir die Dezimalstellen einzelnen Speichervariablen zuordnen.

# Ok cool ist mir eigentlich egal, wie benutze ich das jetzt?
Die Library hat 2 primitive Funktionen
1. VarsExt.create(size)
+ Das ist die Funktion um die du nicht herum kommst. Man übergibt der Funktion einen Parameter size, der die Anzahl an Dezimalstellen, die du benutzen kannst. Zurück bekommt man ein "Objekt", welches eine Zahl zwischen 0 und 10^size - 1 darstellen kann. Sei also gewarnt, dass du bei einer size von 3 nur Zahlen von 0 bis 999 speichern kannst, also reserviere deinen Variablen immer genug Platz, sodass es nicht zu Fehlern kommt.
2. VarsExt.occupy(var)
+ Benutzt du in deinem Script z.B. Vars.Save2 kannst du bevor du Vars.create aufrufst VarsExt.occupy(2) machen, sodass die Library dann diese Variable nicht benutzt. 
    
  (Ich habe mir auch überlegt VarsExt.delete(savevar) und VarsExt.unoccupy(var) zu machen, jedoch würde dies beim Programmieren nur für mehr Verwirrung sorgen und somit sind diese Funktionen nicht im Script enthalten)
  
Um jetzt die Speicherobjekte, welche von VarsExt.create zurückgegeben werden benutzen kann, benutzt man zwei Memberfunktionen

1. sVar:save(num)
+ speichert die Zahl num in der Variable
2. sVar:get()
+ gibt die Zahl zurück.

Ein ganzes Beispiel sieht dann so aus:
```lua

-- Vars.Save2 wird von der Library nicht benutzt, wir benutzen sie selber im Skript
VarsExt.occupy(2)
-- create für eine Variable nur einmalig (am besten im globalen Bereich des Skripts)
mySaveVar = VarsExt.create(3)


mySaveVar:save(10) -- Speicher die Zahl 10
local saveVarValue = mySaveVar:get() -- saveVarValue ist 10
dbg.stm(saveVarValue) -- gibt die Zahl 10 aus :)

-- durch VarsExt.occupy(2) können wir sicher sein, dass mySaveVar nicht Vars.Save2 besetzt
Vars.Save2 = -200



```

# Probleme

+ Es ist nicht möglich negative Zahlen und Kommazahlen darzustellen
+ Benutzt du nicht occupy, aber dennoch eine Vars.Save die die Library benutzt, wird! es zu Fehlern kommen
+ Es ist nicht möglich z.B. mySaveVar = mySaveVar + 10 zu schreiben, stattdessen muss man mySaveVar:save(mySaveVar:get() + 10) schreiben
