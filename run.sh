#!/bin/zsh

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############

# Creating mix2numerical.fst
echo "Creating mix2numerical.fst by combining parser with date structure"
fstconcat compiled/mmm2mm.fst compiled/pass-numbers-and-slash.fst compiled/mix2numerical.fst

# Creating pt2en.fst
echo "Creating pt2en.fst by combining translator with date structure"
fstconcat compiled/pt2en_months.fst compiled/pass-numbers-and-slash.fst compiled/pt2en.fst

# Creating en2pt.fst
echo "Creating en2pt.fst by inverting pt2en.fst"
fstinvert compiled/pt2en.fst compiled/en2pt.fst

# Creating datenum2text.fst
echo "Creating datenum2text.fst by concating month.fst, day.fst, year.fst and other aux fsts"
fstconcat compiled/month.fst compiled/slash-eps.fst compiled/datenum2text.fst
fstconcat compiled/datenum2text.fst compiled/day.fst compiled/datenum2text.fst
fstconcat compiled/datenum2text.fst compiled/slash-comma.fst compiled/datenum2text.fst
fstconcat compiled/datenum2text.fst compiled/year.fst compiled/datenum2text.fst

# ############ generate PDFs  ############
echo "Starting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

# ############      3 different ways of testing     ############
# ############ (you can use the one(s) you prefer)  ############

#1 - generates files
# echo "\n***********************************************************"
# echo "Testing 4 (the output is a transducer: fst and pdf)"
# echo "***********************************************************"
# for w in compiled/t-*.fst; do
#     fstcompose $w compiled/year.fst | fstshortestpath | fstproject --project_type=output |
#                   fstrmepsilon | fsttopsort > compiled/$(basename $w ".fst")-out.fst
# done
# for i in compiled/t-*-out.fst; do
# 	echo "Creating image: images/$(basename $i '.fst').pdf"
#    fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
# done


#2 - present the output as an acceptor
# echo "\n***********************************************************"
# echo "Testing 1 2 3 4 (output is a acceptor)"
# echo "***********************************************************"
# trans=en2pt.fst
# echo "\nTesting $trans"
# for w in "SEP/9/2023" "SEP/21/2024"; do
#     echo "\t $w"
#     python3 ./scripts/word2fst_modified.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
#                      fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
#                      fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=syms.txt
# done

#3 - presents the output with the tokens concatenated (uses a different syms on the output)
fst2word() {
    awk '{if(NF>=3){printf("%s",$3)}}END{printf("\n")}'
}

# trans=en2pt.fst
trans=datenum2text.fst
echo "\n***********************************************************"
echo "Testing"
echo "***********************************************************"
for w in "10/9/2023" "10/21/2024"; do
# for w in "AUG/9/2023" "DEZ/9/2023"; do
    res=$(python3 ./scripts/word2fst.py -s syms.txt $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

echo "\nThe end"
