<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://w3.org">
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Kuninglik Sugupuu - Elizabeth II järglased</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; color: #333; }
                    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
                    th, td { border: 1px solid #dddddd; text-align: left; padding: 10px; }
                    th { background-color: #f5f5f5; }
                    .roheline { background-color: #98FB98; font-weight: bold; }
                    .section { margin-bottom: 35px; border-bottom: 1px solid #eee; padding-bottom: 20px; }
                    input { padding: 6px; margin-right: 10px; }
                </style>
            </head>
            <body>
                <h1>Sugupuu analüüs (Elizabeth II ja järglased)</h1>

                <!-- NÕUE 1: Trüki välja kõikide inimeste sünniaastad -->
                <div class="section">
                    <h3>1. Kõikide inimeste sünniaastad:</h3>
                    <p>
                        <xsl:for-each select="//pereliige">
                            <xsl:value-of select="nimi"/> (<xsl:value-of select="@synniaasta"/>)
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </p>
                </div>

                <!-- NÕUE 2: Väljasta nimed, kellel on vähemalt kaks last -->
                <div class="section">
                    <h3>2. Nimed, kellel on vähemalt kaks last:</h3>
                    <ul>
                        <xsl:for-each select="//pereliige">
                            <xsl:variable name="lasteArv" select="count(pereliikmed/pereliige)"/>
                            <xsl:if test="$lasteArv &gt;= 1">
                                <li>
                                    <strong><xsl:value-of select="nimi"/></strong> – <xsl:value-of select="$lasteArv"/> last
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </div>

                <!-- NÕUED 3, 4, 5, 7 ja 10: SUGUPUU ANDMED TABELINA -->
                <div class="section">
                    <h3>3-7. Andmete tabel:</h3>
                    <table id="sugupuuTabel">
                        <thead>
                            <tr>
                                <th>Nimi</th>
                                <th>Sünniaasta</th>
                                <th>Vanema nimi</th>
                                <th>Vanavanema nimi</th>
                                <th>Mitmendal vanema aastal sündis</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="//pereliige">
                                <tr>
                                    <!-- NÕUE 10: Kõik nimed, mille pikkus on alla 7 värvida roheliseks -->
                                    <xsl:if test="string-length(nimi) &lt; 7">
                                        <xsl:attribute name="class">roheline</xsl:attribute>
                                    </xsl:if>
                                    
                                    <!-- Nimi -->
                                    <td><xsl:value-of select="nimi"/></td>
                                    
                                    <!-- NÕUE 9: Sünniaasta on atribuudiks (@synniaasta) -->
                                    <td><xsl:value-of select="@synniaasta"/></td>
                                    
                                    <!-- NÕUE 4: Kus võimalik, seal väljasta tabelis iga inimese vanema nimi -->
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="../../nimi">
                                                <xsl:value-of select="../../nimi"/>
                                            </xsl:when>
                                            <xsl:otherwise>-</xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    
                                    <!-- NÕUE 5: Väljasta tabelis ka vanavanema nimi -->
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="../../../../nimi">
                                                <xsl:value-of select="../../../../nimi"/>
                                            </xsl:when>
                                            <xsl:otherwise>-</xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    
                                    <!-- NÕUE 7: Väljasta iga inimese juures, mitmendal oma vanema sünniaastal ta sündis -->
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="../../@synniaasta">
                                                <xsl:value-of select="@synniaasta - ../../@synniaasta"/>
                                            </xsl:when>
                                            <xsl:otherwise>-</xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>

                <!-- NÕUE 6: Kuva iga lapse vanus (laps - inimene, kellel pole järglasi) -->
                <div class="section">
                    <h3>6. Laste (järglasteta pereliikmete) vanused aastal 2026:</h3>
                    <ul>
                        <xsl:for-each select="//pereliige">
                            <xsl:if test="not(pereliikmed/pereliige)">
                                <li>
                                    <xsl:value-of select="nimi"/> – <xsl:value-of select="2026 - @synniaasta"/> aastat vana
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </div>

                <!-- NÕUE 8: Tehke vormid ja teostage otsing sümbolite ja pikkuse järgi -->
                <div class="section">
                    <h3>8. Otsing nime sümbolite ja pikkuse järgi:</h3>
                    <form onsubmit="return false;">
                        <input type="text" id="otsiNimi" placeholder="Otsi sümboleid (nt. Ch)..." onkeyup="filtreeriTabelit()"/>
                        <input type="number" id="otsiPikkus" placeholder="Maksimaalne nime pikkus..." oninput="filtreeriTabelit()"/>
                    </form>
                </div>

                <!-- JavaScript reaalajas filtreerimiseks -->
                <script type="text/javascript">
                    //<![CDATA[
                    function filtreeriTabelit() {
                        var tekstiFilter = document.getElementById('otsiNimi').value.toLowerCase();
                        var pikkuseFilter = parseInt(document.getElementById('otsiPikkus').value);
                        
                        var tabel = document.getElementById('sugupuuTabel');
                        var read = tabel.getElementsByTagName('tr');

                        for (var i = 1; i < read.length; i++) {
                            var lahter = read[i].getElementsByTagName('td');
                            if (lahter && lahter[0]) {
                                var nimeTekst = lahter[0].textContent || lahter[0].innerText;
                                var nimePikkus = nimeTekst.trim().length;

                                var tekstKlapib = nimeTekst.toLowerCase().indexOf(tekstiFilter) > -1;
                                var pikkusKlapib = isNaN(pikkuseFilter) || nimePikkus <= pikkuseFilter;

                                if (tekstKlapib && pikkusKlapib) {
                                    read[i].style.display = "";
                                } else {
                                    read[i].style.display = "none";
                                }
                            }
                        }
                    }
                    //]]>
                </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
