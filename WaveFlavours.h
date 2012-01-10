#define SAMPLE_RATE 8000
#define TABLE_LEN 256

class PhaseCounter {
    public :
        float x, oldX, dx, max;
        void start(float d, float m);
        int next();
        bool flipped();
        bool wrapped();
};

class Voice {
   public :
       PhaseCounter play, phaser;
       void start();
       int next(int wave1[]);
       void setPhaserSpeed(float speed);
       void setPitch(int note);
};
