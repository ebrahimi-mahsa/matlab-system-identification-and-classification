function model = myClassifier(U,Y)
% myClassifier trains a linear SVM classifier.


    model = fitcsvm(U,Y,'KernelFunction','linear');

end