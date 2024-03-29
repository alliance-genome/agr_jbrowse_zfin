#!bin/bash

set -e

if [ -z "$1" ]
then
    AWSACCESS=${AWS_ACCESS_KEY}
else
    AWSACCESS=$1
fi

if [ -z "$2" ]
then
    AWSSECRET=${AWS_SECRET_KEY}
else
    AWSSECRET=$2
fi

if [ -z ${AWS_S3_BUCKET} ]
then
    AWSBUCKET=agrjbrowse
else
    AWSBUCKET=${AWS_S3_BUCKET}
fi

cd /jbrowse

FILES=(
'additional_transcripts.gff3'
'E_antibody.gff3'
'E_phenotype.gff3'
'E_expression.gff3'
'zfin_genes.gff3'
'zfin_tginsertion.gff3'
'E_full_zfin_clone.gff3'
'E_trim_zfin_clone.gff3'
'E_zfin_knockdown_reagents.gff3'
#'zfin_zmp.gff3'
'zfin_mutants.gff3'
)

TYPES=(
'V_gene_segment,C_gene_segment,D_gene_segment,J_gene_segment,lnc_RNA,miRNA,mRNA,ncRNA,pseudogenic_transcript,rRNA,scRNA,snoRNA,snRNA,tRNA,unconfirmed_transcript'
'protein_coding_gene'
'protein_coding_gene,lincRNA_gene,lncRNA_gene'
'lincRNA_gene,protein_coding_gene,pseudogene'
'gene,lincRNA_gene,lncRNA_gene,pseudogene,J_gene_segment'
'Transgenic_insertion'
'contig,genomic_clone'
'contig,tiling_path_clone'
'DNA_binding_site,morpholino_oligo,nuclease_binding_site'
#'sequence_alteration'
'sequence_alteration'
)

LABELS=(
'Additional_Transcripts'
'ZFIN_Genes_with_Antibody_Data'
'ZFIN_Genes_with_Phenotype'
'ZFIN_Genes_with_Expression'
'ZFIN_Gene'
'Transgenic_Insertion'
'Complete_Assembly_Clones'
'Assembly'
'Knockdown_Reagent'
#'Zebrafish_Mutation_Project'
'ZFIN_Features'
)

parallel -j "96%" wget -q  http://zfin.org/downloads/{} 2>&1 ::: "${FILES[@]}"

parallel --link -j "96%"  bin/flatfile-to-json.pl --trackType CanvasFeatures  --compress --gff {1} --type {2} --trackLabel {3} ::: "${FILES[@]}" ::: "${TYPES[@]}" ::: "${LABELS[@]}"

#start track uploads while running the name indexer
for label in "${LABELS[@]}"; do
    AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY aws s3 cp --quiet --recursive --content-encoding gzip --acl public-read data/tracks/$label s3://agrjbrowse/MOD-jbrowses/zfin/tracks/$label &
done

echo "Running name indexer..."
bin/generate-names.pl --compress 2>&1


#the upload_to_S3.pl script is in the agr_jbrowse_config repo
#this command is run in a jbrowse directory
/agr_jbrowse_config/scripts/upload_to_S3.pl --bucket $AWSBUCKET --local data --remote MOD-jbrowses/zfin --skipseq --skiptracks --awsaccess $AWSACCESS --awssecret $AWSSECRET 2>&1

# s3://agrjbrowse/MOD-jbrowses/zfin/

