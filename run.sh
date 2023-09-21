#!/bin/zsh

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############













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

trans=day.fst
echo "\n***********************************************************"
echo "Testing 5 6 7 8  (output is a string  using 'syms-out.txt')"
echo "***********************************************************"
# for w in "DEC/9/2023" "DEC/21/2024"; do
for w in "01" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "30" "31"; do
    res=$(python3 ./scripts/word2fst_modified.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

echo "\nThe end"
