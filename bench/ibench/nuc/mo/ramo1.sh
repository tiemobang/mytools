nr=$1
nrt=$2
dop=$3
nsecs=$4
mbd=$5
dev=$6

for dc in mo40.6 mo40.5 ; do
for ver in mo4018 mo4017 mo4016 ; do
  rm $mbd/mo40
  ln -s $mbd/$ver $mbd/mo40
  mkdir perf.${ver}
  bash rall1.sh $dc $dop $nsecs $mbd/ibench/perf.${ver} $nr $nrt $dev no $mbd
done
done

for dc in mo42.6 mo42.5 ; do
for ver in mo425 mo424 mo423 mo422 mo421 ; do
  rm $mbd/mo42
  ln -s $mbd/$ver $mbd/mo42
  mkdir perf.${ver}
  bash rall1.sh $dc $dop $nsecs $mbd/ibench/perf.${ver} $nr $nrt $dev no $mbd
done
done

for dc mo44.6 mo44.5 ; do
for ver in mo44pre mo440rc0 mo44rc1 ; do
  rm $mbd/mo44
  ln -s $mbd/$ver $mbd/mo44
  mkdir perf.${ver}
  bash rall1.sh $dc $dop $nsecs $mbd/ibench/perf.${ver} $nr $nrt $dev no $mbd
done
done
