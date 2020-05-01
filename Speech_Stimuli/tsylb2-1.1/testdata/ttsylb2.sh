#! /bin/sh
###
### File ttsylb2.sh
### Shell script to proof-test tsylb2
###
cd ..
tsylb2 -n phon1ax.pcd 0 < testdata/test1.in > testdata/test1nx.out
diff testdata/test1n.out testdata/test1nx.out
tsylb2 -f phon1ax.pcd 0 < testdata/test1.in > testdata/test1fx.out
diff testdata/test1f.out testdata/test1fx.out
