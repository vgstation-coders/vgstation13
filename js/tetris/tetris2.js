document.open("text/plain");
document.writeln("<table border=4 cellpadding=4 cellspacing=6 bgcolor=#C0B0A0><tr><td>");
for (j=0; j < MaxY; j++)
{ document.writeln("<NOBR>");
  for (i=0; i < MaxX; i++)
    document.write("<IMG src=\"tetris_0.gif\" border=0>");
  document.writeln("</NOBR><BR>");
}
document.writeln("</td></tr></table>");

if (navigator.appName == "Konqueror")
{ document.write("</td><td>");
  document.write("<input width=0 height=0 style=\"width:0; height:0\" name=\"KeyCatch\" onBlur=\"KeyCatchFocus()\" onKeyUp=\"KeyCatchChange()\">");
  KeyCatchFocus();
  IsHideFocus=false;
}
function KeyCatchFocus()
{ setTimeout("document.forms[0].KeyCatch.focus()",100);
}
function KeyCatchChange()
{ var vv=""+document.forms[0].KeyCatch.value;
  if (vv=="") return;
  KeyDown(vv.charCodeAt(0));
  document.forms[0].KeyCatch.value="";
}

document.close();