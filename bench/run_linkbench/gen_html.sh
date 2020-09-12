title=$1
m=$2
conf=$3
nsecs=$4

function catme {
  fn=$1
  if [ -a $fn ]; then
    cat $fn
  else
    echo "$fn not found"
    exit -1
  fi
}

cat <<HeaderEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
     content="width=device-width, initial-scale=1, user-scalable=yes">

  <title>${title}</title>
</head>
<body>
HeaderEOF

cat <<StyleEOF
<style type="text/css">
  table td#cmin { background-color:#FF9A9A }
  table td#cmax { background-color:#81FFA6 }
  td {
    text-align:right
  }
</style>
StyleEOF

steps=( l.pre l.post L1.P8 L2.P8 L3.P12 L4.P12 L5.P16 L6.P16 )

stepTxt=( \
"l.pre: load ${m} million rows (documents) without secondary index on Linktable" \
"l.post: create secondary index on Linktable" \
"L1.P8: transactions with 8 clients, run for $nsecs seconds" \
"L2.P8: transactions with 8 clients, run for $nsecs seconds" \
"L3.P12: transactions with 12 clients, run for $nsecs seconds" \
"L4.P12: transactions with 12 clients, run for $nsecs seconds" \
"L5.P16: transactions with 16 clients, run for $nsecs seconds" \
"L6.P16: transactions with 16 clients, run for $nsecs seconds" \
)

opTxt=( \
"Inserts/s" \
"Indexed rows/s" \
"Transactions/s" \
"Transactions/s" \
"Transactions/s" \
"Transactions/s" \
"Transactions/s" \
"Transactions/s" \
)

# ----- Generate Intro

cat <<IntroEOF
<div id="intro">
<h1 id="intro">Introduction</h1>
<p>
This is a report for Linkbench with $title.
It is generated by scripts.
An overview of Linkbench <a href="http://smalldatum.blogspot.com/2017/06/all-about-linkbench.html">is here</a>.
Below, by <b>DBMS</b>, I mean DBMS+version.config.
An example is <b>my8020.c10b40</b> where <b>my</b> means MySQL, 8020 is version 8.0.20 and c10b40 is the name for the configuration file.
All configurations are currently <a href="https://github.com/mdcallag/mytools/tree/master/bench/conf/dsi.aws">stored here</a>.
</p>
IntroEOF

catme $conf

# ----- Generate ToC

cat <<ToCStartEOF
<div id="toc">
<hr />
<h1 id="toc">Contents</h1>
<ul>
<li><a href="#summary">Summary</a>
ToCStartEOF

for sx in $( seq ${#steps[@]}  ) ; do
x=$(( $sx - 1 ))

cat <<SecEOF
<li>${stepTxt[$x]}
<ul>
<li><a href="#${steps[$x]}.graph">graph</a>
<li><a href="#${steps[$x]}.metrics">metrics</a>
SecEOF

s=${steps[$x]}
if [[ $s != "l.pre" && $s != "l.post" ]]; then
  printf "<li><a href="#${steps[$x]}.rt">response time</a>\n"
fi

printf "</ul>\n"

done

cat <<ToCEndEOF
</ul>
</div>
ToCEndEOF

# ----- Generate summary

cat <<SumEOF
<hr />
<h1 id="summary">Summary</h1>
<p>
Numbers are inserts/s for l.pre, indexed rows/s for l.post and transactions/s for the transaction tests (L*.P*).
The range of values is split into 3 steps: bottom 25&#37;, middle 50&#37;, top 25&#37;.
Values in the bottom have a red background, values in the top have a green background.
The <b>l</b> in l.pre and l.post stands for <b>load</b>. The <b>L</b> in L1.* to L6.* stands for <b>loop</b> and the transaction tests are run in that sequence.
The <b>P</b> in L*.P8, L*.P12 and L*.P16 stands for <b>parallel</b> and represents the number of concurrent clients.
</p>
SumEOF

catme z2.tab

# ----- Generate graph sections

for sx in $( seq ${#steps[@]}  ) ; do
x=$(( $sx - 1 ))
s=${steps[$x]}
tTxt=${stepTxt[$x]}
oTxt=${opTxt[$x]}

cat <<H0XpsEOF
<hr />
<h1 id="${s}.graph">${s}</h1>
<p>${tTxt}.</p>

<p>${oTxt} average</p>
<img src = "ch.${s}.xps.png" alt = "Image" />
H0XpsEOF

cat <<H1XpsEOF
<p>HW performance results normalized by throughput. Legend <a href="https://mdcallag.github.io/linkbench-results.html">is here</a></p>
<pre>
H1XpsEOF
catme z.${s}.eff.op
printf "</pre>\n"

cat <<H2XpsEOF
<p>HW performance results not normalized by throughput. Legend <a href="https://mdcallag.github.io/linkbench-results.html">is here</a></p>
<pre>
H2XpsEOF
catme z.${s}.eff.sec
printf "</pre>\n"

if [[ $x -gt 1 ]]; then

cat <<H3XpsEOF
<p>Reponse time for Link operations. Legend <a href="https://mdcallag.github.io/linkbench-results.html">is here</a>
Entries in the header that end with <b>9</b> are p99, <b>x</b> are max and <b>m</b> are mean. All values are in milliseconds.</p>
<pre>
H3XpsEOF
catme z.${s}.rt.link
printf "</pre>\n"

cat <<H4XpsEOF
<p>Reponse time for Node operations. Legend <a href="https://mdcallag.github.io/linkbench-results.html">is here</a>
Entries in the header that end with <b>9</b> are p99, <b>x</b> are max and <b>m</b> are mean. All values are in milliseconds.</p>
<pre>
H4XpsEOF
catme z.${s}.rt.node
printf "</pre>\n"

fi

done

# ----- Generate metrics sections

for sx in $( seq ${#steps[@]}  ) ; do

x=$(( $sx - 1 ))
s=${steps[$x]}
tTxt=${stepTxt[$x]}
oTxt=${opTxt[$x]}

cat <<MetricH1EOF
<hr />
<h1 id="${s}.metrics">${s}</h1>
<p>$tTxt</p>
<p>
HW performance results for all DBMS tested, not just the ones listed above. Most are normaolized by throughput.
Legend for results <a href="https://mdcallag.github.io/linkbench-results.html">is here</a>.</p>
</p>
<pre>
MetricH1EOF

if [[ $x -le 1 ]]; then
  catme z1.${s}.eff.op
else
  catme z3.r.eff.op.${s}
fi
echo "</pre>"

cat <<MetricH2EOF
<p>
HW performance results for all DBMS tested, not just the ones listed above. Not normalized by throughput.
Legend for results <a href="https://mdcallag.github.io/linkbench-results.html">is here</a>.</p>
</p>
<pre>
MetricH2EOF
if [[ $x -le 1 ]]; then
  catme z1.${s}.eff.sec
else
  catme z3.r.eff.sec.${s}
fi
echo "</pre>"

done

# ----- Generate response time sections

for sx in $( seq ${#steps[@]}  ) ; do

x=$(( $sx - 1 ))
s=${steps[$x]}
tTxt=${stepTxt[$x]}
oTxt=${opTxt[$x]}

if [[ $s == "l.pre" || $s == "l.post" ]]; then
  continue
fi

cat <<RtH1EOF
<hr />
<h1 id="${s}.rt">${s}</h1>
<p>
<ul>
<li>$tTxt
<li>Legend for results <a href="https://mdcallag.github.io/linkbench-results.html">is here</a>.
<li>Entries in the header that end with <b>9</b> are p99, <b>x</b> are max and <b>m</b> are mean. All values are in milliseconds.</p>
</ul>
</p>
<p>Response time for Link operations.</p>
<pre>
RtH1EOF

catme z4.r.rt.link.${s}
echo "</pre>"

cat <<RtH2EOF
<p>Response time for Node operations.</p>
<pre>
RtH2EOF

catme z4.r.rt.node.${s}
echo "</pre>"

done

# ----- bye

cat <<FooterEOF
</body>
</html>
FooterEOF
