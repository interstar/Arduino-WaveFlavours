
class PhaseCounter {
    public :
        float x, oldX, dx, max;
        void start(float d, float m);
        int next();
        bool flipped();
        bool wrapped();
};

