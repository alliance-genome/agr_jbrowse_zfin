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
'E_antibody.gff3'
'E_phenotype.gff3'
'E_expression.gff3'
'zfin_genes.gff3'
'zfin_tginsertion.gff3'
'E_full_zfin_clone.gff3'
'E_trim_zfin_clone.gff3'
'E_zfin_knockdown_reagents.gff3'
'additional_transcripts.gff3'
'zfin_zmp.gff3'
'zfin_mutants.gff3'
)

FF2JSONARGS=(
'\ --gff\ E_antibody.gff3\ --type\ protein_coding_gene\ --key\ "ZFIN Genes with Antibody Data"\ --trackType\ CanvasFeatures\ --trackLabel\ "ZFIN Genes with Antibody Data"\ --compress'
' --gff E_phenotype.gff3 --type protein_coding_gene,lincRNA_gene,lncRNA_gene --key "ZFIN Genes with Phenotype" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Phenotype" --compress'
' --gff E_expression.gff3 --type lincRNA_gene,protein_coding_gene,pseudogene --key "ZFIN Genes with Expression" --trackType CanvasFeatures --trackLabel "ZFIN Genes with Expression" --compress'
' --gff zfin_genes.gff3 --type gene,lincRNA_gene,lncRNA_gene,pseudogene,J_gene_segment --key "ZFIN Gene" --trackType CanvasFeatures --trackLabel "ZFIN Gene" --compress'
' --gff zfin_tginsertion.gff3 --type Transgenic_insertion --key "Transgenic Insertion" --trackType CanvasFeatures --trackLabel "Transgenic Insertion" --compress'
' --gff E_full_zfin_clone.gff3 --type contig,genomic_clone --key "Complete Assembly Clones" --trackType CanvasFeatures --trackLabel "Complete Assembly Clones" --compress'
' --gff E_trim_zfin_clone.gff3 --type contig,tiling_path_clone --key "Assembly" --trackType CanvasFeatures --trackLabel "Assembly" --compress'
'  --gff E_zfin_knockdown_reagents.gff3 --type DNA_binding_site,morpholino_oligo,nuclease_binding_site --key "Knockdown Reagent" --trackType CanvasFeatures --trackLabel "Knockdown Reagent" --compress'
' --gff additional_transcripts.gff3 --type V_gene_segment,C_gene_segment,D_gene_segment,J_gene_segment,lnc_RNA,miRNA,mRNA,ncRNA,pseudogenic_transcript,rRNA,scRNA,snoRNA,snRNA,tRNA,unconfirmed_transcript  --key "Additional Transcripts" --trackType CanvasFeatures --trackLabel "Additional Transcripts" --compress'
' --gff zfin_zmp.gff3 --type sequence_alteration --key "Zebrafish Mutation Project" --trackType CanvasFeatures --trackLabel "Zebrafish Mutation Project" --compress'
' --gff zfin_mutants.gff3 --type sequence_alteration --key "ZFIN Features" --trackType CanvasFeatures --trackLabel "ZFIN Features" --compress1'
)

parallel -j 3 wget -q  http://zfin.org/downloads/{} 2>&1 ::: "${FILES[@]}"

parallel -j 3  bin/flatfile-to-json.pl {} ::: "${FF2JSONARGS[@]}"

echo "Running name indexer..."
bin/generate-names.pl --compress 2>&1


#the upload_to_S3.pl script is in the agr_jbrowse_config repo
#this command is run in a jbrowse directory
/agr_jbrowse_config/scripts/upload_to_S3.pl --bucket $AWSBUCKET --local data --remote MOD-jbrowses/zfin --skipseq --awsaccess $AWSACCESS --awssecret $AWSSECRET 2>&1

# s3://agrjbrowse/MOD-jbrowses/zfin/

