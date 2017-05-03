#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/Rand.h"
#include "cinder/gl/gl.h"
#include "cinder/params/Params.h"

using namespace ci;
using namespace ci::app;
using namespace std;

struct Particle
{
    vec3 pos;
    ColorA color;
};

const int NUM_PARTICLES = 2000;

class LorenzSystemApp : public App {
public:
    void setup() override;
    void mouseDown( MouseEvent event ) override;
    void update() override;
    void draw() override;
    
    params::InterfaceGlRef	mParams;
    
private:
    void setLorentzProps(gl::GlslProgRef prog);
    
    gl::GlslProgRef mRenderProg;
    gl::GlslProgRef mUpdateProg;
    
    // Descriptions of particle data layout.
    gl::VaoRef mAttributes[2];
    
    // Buffers holding raw particle data on GPU.
    gl::VboRef mParticleBuffer[2];
    
    // Current source and destination buffers for transform feedback.
    // Source and destination are swapped each frame after update.
    std::uint32_t mSourceIndex = 0;
    std::uint32_t mDestinationIndex	= 1;
    
    float uSigma;
    float uRho;
    float uBeta;
    int uIteration;
    float uDt;
};

void prepareSettings(LorenzSystemApp::Settings *settings)
{
    settings->setHighDensityDisplayEnabled(); // try removing this line
    settings->setMultiTouchEnabled(false);
    settings->setWindowSize(1024, 768);
    settings->setFrameRate(45.0f);
    
    // on iOS we want to make a Window per monitor
#if defined( CINDER_COCOA_TOUCH )
    for(auto display : Display::getDisplays())
        settings->prepareWindow(Window::Format().display(display));
#endif
}

void LorenzSystemApp::setup()
{
    uSigma = 10.0f;
    uRho = 30.2f;
    uBeta = 8.0f / 3.0f;
    uIteration = 64;
    uDt = 0.004f;
    
    mParams = params::InterfaceGl::create(getWindow(), "parameters", toPixels(ivec2( 200, 400)));
    mParams->addParam("sigma", &uSigma).min(0.5f).max(20.0f).step(0.5f);
    mParams->addParam("rho", &uRho).min(10.0f).max(40.0f).step(1.0f);
    mParams->addParam("beta", &uBeta).min(0.1f).max(10.0f).step(0.1f);
    
    mParams->addParam("iteration", &uIteration).min(16).max(128).step(1);
    mParams->addParam("dt", &uDt).min(0.0005f).max(0.01f).step(0.0002f);
    
    vector<Particle> particles;
    particles.assign(NUM_PARTICLES, Particle());
    
    vector<Color> colors;
    colors.push_back(Color(0.6f, 0.62f, 0.9f));
    colors.push_back(Color(0.8f, 0.2f, 0.55f));
    colors.push_back(Color(0.9f, 0.9f, 0.45f));
    
    for(int i = 0; i < particles.size(); i++) {
        auto &p = particles.at(i);
        p.pos = Rand::randVec3() * 10.0f;
        // p.color = Color(CM_HSV, lmap<float>(i, 0.0f, particles.size(), 0.0f, 0.66f), 1.0f, 1.0f);
        p.color = colors.at(Rand::randInt(colors.size()));
    }
    
    mParticleBuffer[mSourceIndex] = gl::Vbo::create(GL_ARRAY_BUFFER, particles.size() * sizeof(Particle), particles.data(), GL_STATIC_DRAW);
    mParticleBuffer[mDestinationIndex] = gl::Vbo::create( GL_ARRAY_BUFFER, particles.size() * sizeof(Particle), nullptr, GL_STATIC_DRAW);
    
    for( int i = 0; i < 2; ++i )
    {	// Describe the particle layout for OpenGL.
        mAttributes[i] = gl::Vao::create();
        gl::ScopedVao vao( mAttributes[i] );
        
        // Define attributes as offsets into the bound particle buffer
        gl::ScopedBuffer buffer( mParticleBuffer[i] );
        gl::enableVertexAttribArray(0);
        gl::enableVertexAttribArray(1);
        // gl::enableVertexAttribArray(2);
        // gl::enableVertexAttribArray(3);
        // gl::enableVertexAttribArray(4);
        gl::vertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, pos) );
        gl::vertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, sizeof(Particle), (const GLvoid*)offsetof(Particle, color) );
    }
    
    // Load our update program.
    // Match up our attribute locations with the description we gave.
    mRenderProg = gl::GlslProg::create(gl::GlslProg::Format()
                                       .vertex(loadAsset("particle.vert"))
                                       .geometry(loadAsset("particle.geom"))
                                       .fragment(loadAsset("particle.frag")));
    
    mUpdateProg = gl::GlslProg::create(gl::GlslProg::Format().vertex(loadAsset("particleUpdate.vs")).                                                                   feedbackFormat(GL_INTERLEAVED_ATTRIBS).feedbackVaryings({ "position", "color" }).attribLocation("iPosition", 0).attribLocation("iColor", 1));
    
    
}

void LorenzSystemApp::mouseDown( MouseEvent event )
{
}

void LorenzSystemApp::update()
{
    gl::ScopedGlslProg prog(mUpdateProg);
    setLorentzProps(mUpdateProg);
    
    gl::ScopedState rasterizer( GL_RASTERIZER_DISCARD, true );	// turn off fragment stage
    
    // Bind the source data (Attributes refer to specific buffers).
    gl::ScopedVao source(mAttributes[mSourceIndex]);
    
    // Bind destination as buffer base.
    gl::bindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, mParticleBuffer[mDestinationIndex]);
    gl::beginTransformFeedback(GL_POINTS);
    
    // Draw source into destination, performing our vertex transformations.
    gl::drawArrays(GL_POINTS, 0, NUM_PARTICLES);
    
    gl::endTransformFeedback();
    
    // Swap source and destination for next loop
    std::swap(mSourceIndex, mDestinationIndex);
}

void LorenzSystemApp::draw()
{
    gl::clear(Color(0, 0, 0));
    gl::setMatricesWindowPersp(getWindowSize(), 60.0f, 1.0f, 10000.0f );
    // gl::enableDepthRead();
    // gl::enableDepthWrite();
    
    gl::ScopedGlslProg render(mRenderProg);
    gl::ScopedDepthTest(false);
    
    gl::ScopedVao vao(mAttributes[mSourceIndex]);
    
    vec3 center = vec3(getWindowCenter(), 0.0f);
    mRenderProg->uniform("uIteration", uIteration);
    setLorentzProps(mRenderProg);
    gl::ScopedLineWidth(3.0f);
    gl::ScopedBlend	blendScope(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    auto t = getElapsedSeconds();
    gl::pushModelMatrix();
    gl::translate(center);
    gl::scale(vec3(6.2f));
    gl::rotate(t * 0.0025f, vec3(0.1, 1, 0));
    
    gl::context()->setDefaultShaderVars();
    
    gl::drawArrays(GL_POINTS, 0, NUM_PARTICLES);
    gl::popModelMatrix();
    
    mParams->draw();
}

void LorenzSystemApp::setLorentzProps(gl::GlslProgRef prog) {
    prog->uniform("uSigma", uSigma);
    prog->uniform("uRho", uRho);
    prog->uniform("uBeta", uBeta);
    prog->uniform("uDt", uDt);
}

CINDER_APP(LorenzSystemApp, RendererGl, prepareSettings)
