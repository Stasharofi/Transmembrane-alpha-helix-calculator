
####################################################################################################################################
####################################################################################################################################
# >>
#' @title alphaHelixCalculation
#' @param df Dataframe for input file data.
#' @param sampleNames Names of the samples found in the input file.
#' @param sampleNamesUpdate Updated names of the samples found in the input file.
#' @param dateTimeCurrent Date and time at the time the simulation began.
# <<
####################################################################################################################################
####################################################################################################################################


####################################################################################################################################
##################################### alphaHelixCalculation() ######################################################################
# >>
alphaHelixCalculation <- function( df, sampleNames, sampleNamesUpdate, dateTimeCurrent ) {

    dataBase_alpha   = select(dataBase_alpha, c(1,2))
    dataBase_reduced = dataBase_alpha

    num_Pro_aaa    = unique(dataBase_reduced$id)
    protein        = vector()
    num_aaa_pro_DB = vector()

    pb_1 = winProgressBar( title = "progress bar",
                           min   = 0,
                           max   = length(num_Pro_aaa),
                           width = 300 )
    i = 1
    for( i in 1 : length(num_Pro_aaa) ) {

        item                = num_Pro_aaa[i]
        proteins            = filter(dataBase_reduced, id == item)
        num_aaa_pro_DB_temp = length(proteins$id)
        num_aaa_pro_DB      = c(num_aaa_pro_DB_temp,num_aaa_pro_DB)
        protein             = c(unique(proteins$id),protein)
        proteins            = vector()
        num_aaa_pro_DB_temp = vector()

        setWinProgressBar( pb_1, i,
                           title = paste( 'Alpha-helix calculation for database     ',
                                          round(i/length(num_Pro_aaa)*100, 0),
                                          "% done") )
    }

    close(pb_1)

    # Calculating the number of amino acids for alpha ####

    aaa              = data.frame( id      = protein,
                                   num_aaa = num_aaa_pro_DB )
    cal_for_database = left_join(  dataBase_numOfAA,
                                   aaa,
                                   by = 'id' )

    Sys.sleep(0.5)

    # Samples ####

    i = 1
    for( i in 1 : length(sampleNames) ) {

        temp = which( names(df) == sampleNames[i] )

        # Peptides in the sample >>

        sample_peptides = filter( df, df[,temp] > 0 )
        write.csv( sample_peptides,
                   gsub( " ", "_", paste0( dateTimeCurrent,
                                           " ", 'List of peptides in',
                                           sampleNamesUpdate[i],
                                           '.csv' ), fixed = FALSE ),
                   row.names = FALSE )

        sample = paste( as.character(sampleNamesUpdate[i]), '_ peptides' )
        assign( sample, sample_peptides )

        # Proteins in the sample >>

        sample_proteins = unique(sample_peptides$Proteins)
        write.csv( sample_proteins,
                   gsub( " ", "_", paste0( dateTimeCurrent,
                                           " ", 'List of proteins in',
                                           sampleNamesUpdate[i],
                                           '.csv' ), fixed = FALSE ),
                   row.names = FALSE )

        sample = paste( as.character(sampleNamesUpdate[i]), '_ proteins' )
        assign( sample, sample_proteins )

        # Calculating alpha helix coverage for samples >>

        proteins_in_s = vector()
        aa_in_s       = vector()
        aaa_in_s      = vector()

        pb_2 = winProgressBar( title = "progress bar",
                               min   = 0,
                               max   = length(sample_proteins),
                               width = 300 )

        j = 1
        for( j in 1 : length(sample_proteins) ) {

            item      = sample_proteins[j]
            Pro_chunk = filter( sample_peptides, sample_peptides$Proteins == item )

            k         = 1
            list_aa_s = vector()

            for( k in 1 : length(Pro_chunk$Proteins) ) {

                start          = Pro_chunk$Start.position[k]
                end            = Pro_chunk$End.position[k]
                list_aa_s_temp = seq(start:end)
                list_aa_s_temp = list_aa_s_temp+start-1
                list_aa_s      = c( list_aa_s_temp, list_aa_s )
                list_aa_s_temp = vector()

            }

            proteins_temp = item
            proteins_in_s = c( proteins_temp, proteins_in_s )
            proteins_temp = vector()

            aa_in_s_temp  = length( unique(list_aa_s) )
            aa_in_s       = c( aa_in_s_temp, aa_in_s )
            aa_in_s_temp  = vector()

            protein_chunk_dataBase = filter( dataBase_reduced, id == item )

            aaa_in_s_temp = unique(list_aa_s)%in%protein_chunk_dataBase$n
            aaa_in_s_temp = sum(aaa_in_s_temp)
            aaa_in_s      = c( aaa_in_s_temp, aaa_in_s )
            aaa_in_s_temp = vector()

            results = data.frame( id                              = proteins_in_s,
                                  num_amino_acids_in_sample       = aa_in_s,
                                  num_alpha_amino_acids_in_sample = aaa_in_s )

            results = left_join( results, cal_for_database, by = 'id' )

            setWinProgressBar( pb_2, j,
                               title = paste( 'Alpha-helix calculation for',
                                              sampleNames[i],
                                              '    ',
                                              round(j/length(sample_proteins)*100, 0),
                                              "% done"))

        }

        write.csv( results,
                   gsub( " ", "_", paste0( dateTimeCurrent,
                                           " ", "alpha helix analysis of",
                                           sampleNamesUpdate[i],
                                           ".csv" ), fixed = FALSE ),
                   row.names = FALSE )

        close(pb_2)

    }

    return( invisible(NULL) )
}
# <<
##################################### alphaHelixCalculation() ######################################################################
####################################################################################################################################
