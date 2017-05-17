#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/Rand.h"
#include "cinder/gl/gl.h"
#include "cinder/params/Params.h"
#include "cinder/CameraUi.h"
#include "cinder/Log.h"

using namespace ci;
using namespace ci::app;
using namespace std;

struct Particle
{
    vec3 position;
    ColorA color;
    vec3 velocity;
    float seed;
};

const int NUM_PARTICLES = 100;
const int POSITION_INDEX = 0;
const int COLOR_INDEX = 1;
const int VELOCITY_INDEX = 2;
const int SEED_INDEX = 3;

class FishApp : public App {
public:
    void setup() override;
    void update() override;
    void draw() override;
    
    void keyDown(KeyEvent event) override;
    void mouseDown(MouseEvent event) override;
    void mouseMove(MouseEvent event) override;
    void mouseUp(MouseEvent event) override;
    void mouseDrag(MouseEvent event) override;
    void mouseWheel(MouseEvent event) override;
    
private:
    gl::GlslProgRef mRenderProg;
    gl::GlslProgRef mUpdateProg;
    
    gl::VaoRef mAttributes[2];
    gl::VboRef mParticleBuffer[2];
    
    std::uint32_t mSourceIndex = 0;
    std::uint32_t mDestinationIndex	= 1;
    
    CameraPersp mViewCam;
    CameraUi mCamUi;
    
    float mWindowScale;
    float mPrev;
};

void FishApp::setup()
{
    mWindowScale = getWindowContentScale();
    
    mViewCam.setEyePoint(vec3(0.0f, 0.0f, -20.0f));
    mViewCam.setPerspective(60, getWindowWidth() / getWindowHeight(), 1, 10000);
    mViewCam.lookAt(vec3(0));
    mCamUi = CameraUi(&mViewCam);
    
    vector<Particle> particles;
    particles.assign(NUM_PARTICLES, Particle());
    
    vector<Color> colors;
    colors.push_back(Color(0.6f, 0.62f, 0.9f));
    colors.push_back(Color(0.8f, 0.2f, 0.55f));
    colors.push_back(Color(0.9f, 0.9f, 0.45f));
    
    for(int i = 0; i < particles.size(); i++) {
        auto &p = particles.at(i);
        p.position = Rand::randVec3() * Rand::randFloat(30.0f);
        p.velocity = Rand::randVec3() * Rand::randFloat(1.0f);
        p.seed = Rand::randFloat();
        p.color = colors.at(Rand::randInt(colors.size()));
    }
    
    mParticleBuffer[mSourceIndex] = gl::Vbo::create(GL_ARRAY_BUFFER, particles.size() * sizeof(Particle), particles.data(), GL_STATIC_DRAW);
    mParticleBuffer[mDestinationIndex] = gl::Vbo::create( GL_ARRAY_BUFFER, particles.size() * sizeof(Particle), nullptr, GL_STATIC_DRAW);
    
    for(int i = 0; i < 2; ++i) {
        mAttributes[i] = gl::Vao::create();
        gl::ScopedVao vao(mAttributes[i]);
        
        gl::ScopedBuffer buffer(mParticleBuffer[i]);
        gl::enableVertexAttribArray(POSITION_INDEX);
        gl::enableVertexAttribArray(COLOR_INDEX);
        gl::enableVertexAttribArray(VELOCITY_INDEX);
        gl::enableVertexAttribArray(SEED_INDEX);
        
        gl::vertexAttribPointer(POSITION_INDEX, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, position) );
        gl::vertexAttribPointer(COLOR_INDEX, 4, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, color) );
        gl::vertexAttribPointer(VELOCITY_INDEX, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, velocity) );
        gl::vertexAttribPointer(SEED_INDEX, 1, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, seed) );
    }
    
    mRenderProg = gl::GlslProg::create(gl::GlslProg::Format()
                                       .vertex(loadAsset("particle.vert"))
                                       .geometry(loadAsset("particle.geom"))
                                       .fragment(loadAsset("particle.frag"))
                                       .attribLocation("Velocity", VELOCITY_INDEX)
                                       .attribLocation("Seed", SEED_INDEX)
                                       );
    
    mUpdateProg = gl::GlslProg::create(gl::GlslProg::Format().vertex(loadAsset("particleUpdate.vs"))
                                       .feedbackFormat(GL_INTERLEAVED_ATTRIBS)
                                       .feedbackVaryings({
                                            "position",
                                            "color",
                                            "velocity",
                                            "seed"
                                        })
                                       .attribLocation("iPosition", POSITION_INDEX)
                                       .attribLocation("iColor", COLOR_INDEX)
                                       .attribLocation("iVelocity", VELOCITY_INDEX)
                                       .attribLocation("iSeed", SEED_INDEX)
                                       );
    
}

void FishApp::update()
{
    gl::ScopedGlslProg prog(mUpdateProg);
    
    float t = getElapsedSeconds();
    mUpdateProg->uniform("uDt", t - mPrev);
    
    gl::ScopedState rasterizer(GL_RASTERIZER_DISCARD, true);	// turn off fragment stage
    
    gl::ScopedVao source(mAttributes[mSourceIndex]);
    
    gl::bindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, mParticleBuffer[mDestinationIndex]);
    gl::beginTransformFeedback(GL_POINTS);
    
    gl::drawArrays(GL_POINTS, 0, NUM_PARTICLES);
    
    gl::endTransformFeedback();
    
    std::swap(mSourceIndex, mDestinationIndex);
    
    mPrev = t;
}

void FishApp::draw()
{
    gl::clear(Color(0, 0, 0));
    
    gl::ScopedGlslProg render(mRenderProg);
    gl::ScopedDepthWrite write(true);
    gl::ScopedDepthTest test(true);
    gl::ScopedFaceCulling cull(GL_FRONT, true);
    
    gl::ScopedVao vao(mAttributes[mSourceIndex]);
    
    vec3 center = vec3(0.0f, 0.0f, 0.0f);
    
    float t = getElapsedSeconds();
    mRenderProg->uniform("uT", t);
    
    // gl::ScopedBlend	blendScope(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // gl::pushModelMatrix();
    
    // auto t = getElapsedSeconds();
    // gl::rotate(t * 0.0025f, vec3(0.1, 1, 0));
    
    gl::pushMatrices();
    gl::setMatrices(mViewCam);
    
    gl::translate(center);
    gl::scale(vec3(2.2f));
    gl::rotate(t * 0.1f, vec3(0, 1, 0));
    
    // gl::viewport(0.0f, 0.0f, getWindowWidth() * mWindowScale, getWindowHeight() * mWindowScale);
    gl::context()->setDefaultShaderVars();
    
    gl::drawArrays(GL_POINTS, 0, NUM_PARTICLES);
    gl::popMatrices();
    
    // mParams->draw();
}

void FishApp::keyDown(KeyEvent event)
{
    if (event.getCode() == KeyEvent::KEY_ESCAPE) quit();
}

void FishApp::mouseDown(MouseEvent event)
{
    mCamUi.mouseDown(event);
}

void FishApp::mouseMove(MouseEvent event)
{
}

void FishApp::mouseUp(MouseEvent event)
{
    mCamUi.mouseUp(event);
}

void FishApp::mouseDrag(MouseEvent event)
{
    Rectf r	= Rectf(0, 0, getWindowWidth() * mWindowScale, getWindowHeight() * mWindowScale);
    if (r.contains(event.getPos())) {
        mCamUi.mouseDrag(event);
    }
}

void FishApp::mouseWheel(MouseEvent event)
{
    mCamUi.mouseWheel(event);
}

CINDER_APP( FishApp, RendererGl )
