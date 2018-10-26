function B = catStructures(A, B)

    fnames = fieldnames(A)' ;

    for iField = fnames
        B.(char(iField)) = A.(char(iField)) ;
    end
    