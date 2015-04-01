#include "SparseConvNet.h"
const int onlineHandwritingCharacterScale = 64;
#include "OnlineHandwritingSimple.h"
#include "readAssamese.h"

Picture* OnlinePicture::distort(RNG& rng, batchType type) {
  OnlinePicture* pic=new OnlinePicture(*this);
  if (type==TRAINBATCH) {
    jiggleStrokes(pic->ops,rng,1);
    stretchXY(pic->ops,rng,0.3);
    int r=rng.randint(3);
    if (r==0) rotate(pic->ops,rng,0.3);
    if (r==1) slant_x(pic->ops,rng,0.3);
    if (r==2) slant_y(pic->ops,rng,0.3);
    jiggleCharacter(pic->ops,rng,12);
  }
  return pic;
}


int epoch=0;
int cudaDevice=-1;

int main() {
  string baseName="weights/Assamese";

  SpatialDataset trainSet=AssameseTrainSet();
  SpatialDataset testSet=AssameseTestSet();

  int batchSize=100;
  trainSet.summary();
  testSet.summary();
  DeepCNet cnn(6,32,RELU,trainSet.nFeatures,trainSet.nClasses,0.0f,cudaDevice);
  if (epoch++>0)
    cnn.loadWeights(baseName,epoch-1);
  for (;;epoch++) {
    cout <<"epoch: " << epoch << flush;
    trainSet.shuffle();
    cnn.processDataset(trainSet, batchSize,0.003*exp(-0.005 * epoch));
    if (epoch%10==0) {
      cnn.saveWeights(baseName,epoch);
      cnn.processDataset(testSet,  batchSize);
    }
  }
}
