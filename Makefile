USE_PDFLATEX =	yes
NAME =		tcpinput-slides
TEXSRCS	=	tcpinput-slides.tex
CLEAN_FILES =	${NAME:=.nav} ${NAME:=.snm} ${NAME:=.vrb} \
		gnuplot/*.{tex,eps} kstack/*.pdf
# make does not support : in file name, it is a variable modifier
# latex does not support . in file name, it is a suffix
DATE =		2025-01-26T17:08:00Z
CVSDATE =	2025-01-26T00:00:00Z
GNUPLOTS = \
    ${DATE} tcp 0,1,2,3 - - - - \

results/${DATE:C/[:.]/-/g}/tcp.data:
	rm -f $@
	mkdir -p results/${DATE}
	cd results/${DATE} && \
	    ftp http://bluhm.genua.de/perform/results/${DATE}/gnuplot/tcp.data
	ln -s ${DATE} results/${DATE:C/[:.]/-/g}

.for d p n x X y Y in ${GNUPLOTS}

TEXSRCS +=	gnuplot/${d:C/[:.]/-/g}-$p${n:N-:S/^/-/}.tex

.PATH: bin

gnuplot/${d:C/[:.]/-/g}-$p${n:N-:S/^/-/}.tex: \
    gnuplot.pl Buildquirks.pm Html.pm Testvars.pm plot.gp \
    results/${DATE:C/[:.]/-/g}/tcp.data
	rm -f $@
	mkdir -p gnuplot
	perl bin/gnuplot.pl -L -d ${DATE} \
	    ${d:M*-*:S/^/-d /} ${d:M*.*:S/^/-r /} \
	    -p $p ${n:N-:S/^/-N /} \
	    ${x:N-:S/^/-x /} ${X:N-:S/^/-X /} \
	    ${y:N-:S/^/-y /} ${Y:N-:S/^/-Y /}
	ln -s $d-$p${n:N-:S/^/-/}.tex $@

.endfor

CMD_fwd_parallel =	iperf3_-c10.3.45.35_-w1m_-P10_-t10
CMD_fwd_single =	iperf3_-c10.3.45.35_-w1m_-t10
CMD_rev_parallel =	iperf3_-c10.3.45.35_-w1m_-P10_-t10_-R
CMD_rev_single =	iperf3_-c10.3.45.35_-w1m_-t10_-R

.for p in ${CVSDATE} sys-tcp-input-parallel sys-tcp-input-solock sys-tcp-mpinput
.for d in fwd rev
.for n in parallel single

OTHER +=		kstack/${p:C/[:.]/-/g}-$d-$n.pdf

kstack/${p:C/[:.]/-/g}-$d-$n.svg:
	rm -f $@
	mkdir -p kstack
	cd kstack && \
	    ftp http://bluhm.genua.de/perform/results/${DATE}/${p:C,^sys-.*,patch-&.0,}/btrace/${CMD_$d_$n}-btrace-kstack.0.svg
	mv kstack/${CMD_$d_$n}-btrace-kstack.0.svg kstack/$p-$d-$n.svg
	[ -f $@ ] || ln -s $p-$d-$n.svg $@

kstack/${p:C/[:.]/-/g}-$d-$n.pdf: kstack/${p:C/[:.]/-/g}-$d-$n.svg
	cd ${@:H} && inkscape --export-type=pdf ${p:C/[:.]/-/g}-$d-$n.svg

.endfor
.endfor
.endfor

.include </usr/local/share/latex-mk/latex.mk>
