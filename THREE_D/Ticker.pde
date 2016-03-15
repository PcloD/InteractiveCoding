
class Ticker {
  
  float ticker = 0f;
  float duration = 0f;
  
  float from = 0f;
  float to = 1f;
  
  public void start(float duration, float from, float to) {
    this.ticker = 0f;
    this.duration = duration;
    this.from = from;
    this.to = to;
  }
  
  public void update(float dt) {
    ticker += dt;
    ticker = min(ticker, duration);
  }
  
  public float getT() {
    if(duration <= 0f) return 0f;
    return lerp(from, to, ticker / duration);
  }

}