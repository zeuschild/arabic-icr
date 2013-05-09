function  [LetterFeaturesMedoids, LetterWaveletsMedoids] = CalcKMedoids(LetterFeatures, LetterWavelets, k)

LetterWaveletsMatrix = cell2mat(LetterWavelets)';
if (size(LetterWaveletsMatrix,1)>2*k)
    [label, energy, index]= kmedoidsL1(LetterWaveletsMatrix',k);
    
    for i=1:k
        LetterWaveletsMedoids(i) = LetterWavelets(index(i));
        LetterFeaturesMedoids(i) = LetterFeatures(index(i));
    end
else
    LetterFeaturesMedoids = LetterFeatures;
    LetterWaveletsMedoids = LetterWavelets;
end