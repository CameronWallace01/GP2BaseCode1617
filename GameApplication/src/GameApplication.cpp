#include "GameApplication.h"

GameApplication::GameApplication()
{
 	m_pWindow=nullptr;
	m_WindowWidth=640;
	m_WindowHeight=480;
	m_WindowCreationFlags=SDL_WINDOW_OPENGL;
	CREATELOG("log.txt");
	m_bIsActive=false;
	m_bIsRunning=false;
}

GameApplication::~GameApplication()
{

}

void GameApplication::createWindow(const string& windowTitle,const unsigned int width, const unsigned int height, const unsigned int windowFlags)
{
  LOG(INFO,"Window Created %s Width - %d Height - %d",windowTitle.c_str(),width,height);
	//Create a window
	m_pWindow = SDL_CreateWindow(
		windowTitle.c_str(),             // window title
		SDL_WINDOWPOS_CENTERED,     // x position, centered
		SDL_WINDOWPOS_CENTERED,     // y position, centered
		width,                        // width, in pixels
		height,                        // height, in pixels
		windowFlags           // flags
		);

		m_WindowWidth=width;
		m_WindowHeight=height;
}

void GameApplication::parseConfig(int args,char * arg[])
{
  stringstream ss;
  //parse config file
  XMLOptionsParser xmlParser=XMLOptionsParser("settings.xml");
  xmlParser.parse(m_Options);
  ss<<m_Options;
  LOG(INFO,"Settings Parsed\n%s",ss.str().c_str());
  ss.str( std::string());
  ss.clear();

	//parse command line arguments into keyvalue pairs, this should
	//overide options in config files
  CommandLineParser commandLineParser=CommandLineParser(args,arg);
  commandLineParser.parse(m_Options);
  ss<<m_Options;
  LOG(INFO,"Command Line Parsed\n%s",ss.str().c_str());
  ss.str( std::string());
  ss.clear();
}

void GameApplication::initGraphics()
{
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    m_GLcontext = SDL_GL_CreateContext(m_pWindow);
    glewExperimental = GL_TRUE;

    GLenum err = glewInit();

    if (GLEW_OK != err)	{
    	LOG(ERROR,"Error: %s",glewGetErrorString(err));
    }

    //Smooth shading
		glShadeModel( GL_SMOOTH );

		//clear the background to black
		glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );

		//Clear the depth buffer to 1.0
		glClearDepth( 1.0f );

		//Enable depth testing
		glEnable( GL_DEPTH_TEST );

		//The depth test to use
		glDepthFunc( GL_LEQUAL );


    setViewport((int)m_WindowWidth,(int)m_WindowHeight);

}

void GameApplication::setViewport( int width, int height )
{
  //screen ration
    GLfloat ratio;

    //make sure height is always above 1
    if ( height == 0 ) {
        height = 1;
    }

    //calculate screen ration
    ratio = ( GLfloat )width / ( GLfloat )height;

    //Setup viewport
    glViewport( 0, 0, ( GLsizei )width, ( GLsizei )height );
}

bool GameApplication::init(int args,char * arg[])
{
  parseConfig(args,arg);

	//Controls the game loop
	m_bIsRunning = true;

  LOG(INFO,"%s","Initialising SDL");
	// init everyting - SDL, if it is nonzero we have a problem
	if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
	{
		//std::cout << "ERROR SDL_Init " << SDL_GetError() << std::endl;
    LOG(ERROR,"SDL can't be initialised %s",SDL_GetError());
		return false;
	}

  int imageInitFlags = IMG_INIT_JPG | IMG_INIT_PNG;
  int returnInitFlags = IMG_Init(imageInitFlags);

  if (((returnInitFlags) & (imageInitFlags)) != imageInitFlags)
  {
    LOG(ERROR,"SDL_Image Init %s",IMG_GetError());
  }

	m_WindowWidth=m_Options.getOptionAsInt("WindowWidth");
	m_WindowHeight=m_Options.getOptionAsInt("WindowHeight");

	createWindow(m_Options.getOption("WindowTitle"),m_WindowWidth,m_WindowHeight,m_WindowCreationFlags);
  initGraphics();

  initScene();

	m_bIsActive=true;
	return true;
}

void GameApplication::initScene()
{

}

void GameApplication::destroyScene()
{

}

void GameApplication::onKeyDown(SDL_Keycode keyCode)
{
}

void GameApplication::OnQuit()
{
	destroyScene();
	//set our boolean which controls the loop to false
	m_bIsRunning = false;
  SDL_GL_DeleteContext(m_GLcontext);
	SDL_DestroyWindow(m_pWindow);
  IMG_Quit();
	SDL_Quit();
	CLOSELOG();
}

void GameApplication::OnMaximize()
{
  LOG(INFO,"%s","Maximize");
}

void GameApplication::OnMinimize()
{
  LOG(INFO,"%s","Minimize");
  m_bIsActive=false;
}

void GameApplication::OnRestored()
{
  LOG(INFO,"%s","Restored");
  m_bIsActive=true;
}

void GameApplication::update()
{

}

void GameApplication::OnBeginRender()
{
  //Set the clear colour(background)
  glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
  //clear the colour and depth buffer
  glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
}

void GameApplication::OnEndRender()
{
  SDL_GL_SwapWindow(m_pWindow);
}

void GameApplication::render()
{

}

void GameApplication::run()
{
	SDL_Event event;
	//Game Loop
	while (m_bIsRunning)
	{
		//While we still have events in the queue
		while (SDL_PollEvent(&event)) {
			//Get event type
			if (event.type == SDL_QUIT) {

				OnQuit();
			}
			if (event.type == SDL_KEYDOWN)
			{
				onKeyDown(event.key.keysym.sym);
				if (event.key.keysym.sym == SDLK_ESCAPE)
				{
					OnQuit();
				}
				if (event.key.keysym.sym == SDLK_f)
				{
					if (SDL_SetWindowFullscreen(m_pWindow, SDL_WINDOW_FULLSCREEN) == -1)
					{
						LOG(ERROR, "Can't Maximize %s", SDL_GetError());
					}
				}
			}
			if (event.type == SDL_WINDOWEVENT)
			{
				switch (event.window.event)
				{
				case SDL_WINDOWEVENT_CLOSE:
				{
					OnQuit();
					break;
				}

				case SDL_WINDOWEVENT_MINIMIZED:
				{
					OnMinimize();
					break;
				}

				case SDL_WINDOWEVENT_MAXIMIZED:
				{
					OnMaximize();
					break;
				}
				case SDL_WINDOWEVENT_RESTORED:
				{
					OnRestored();
					break;
				}
				}
			}
		}
		//messages have been handled now do our work for the game
		if (m_bIsActive && m_bIsRunning) {
      update();
      OnBeginRender();
      render();
      OnEndRender();

		}
	}
}
