//--------------------------------------------------------------------------------------
// Copyright 2013 Intel Corporation
// All Rights Reserved
//
// Permission is granted to use, copy, distribute and prepare derivative works of this
// software for any purpose and without fee, provided, that the above copyright notice
// and this statement appear in all copies.  Intel makes no representations about the
// suitability of this software for any purpose.  THIS SOFTWARE IS PROVIDED "AS IS."
// INTEL SPECIFICALLY DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, AND ALL LIABILITY,
// INCLUDING CONSEQUENTIAL AND OTHER INDIRECT DAMAGES, FOR THE USE OF THIS SOFTWARE,
// INCLUDING LIABILITY FOR INFRINGEMENT OF ANY PROPRIETARY RIGHTS, AND INCLUDING THE
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  Intel does not
// assume any responsibility for any errors which may appear in this software nor any
// responsibility to update it.
//--------------------------------------------------------------------------------------
#ifndef __CPUTTEXT_H__
#define __CPUTTEXT_H__

#include "CPUTControl.h"
#include "CPUTGuiController.h"

class CPUTFont;

// Button base - common functionality for all the controls
//-----------------------------------------------------------------------------
class CPUTText : public CPUTControl
{
public:

	static CPUTText* Create(CPUTFont* mpFont);
    static CPUTText* Create(std::string const& String, CPUTControlID id, CPUTFont *pFont);

    virtual ~CPUTText();

    //Management
    virtual void GetString(std::string &ButtonText);

    //CPUTEventHandler
    virtual CPUTEventHandledCode HandleKeyboardEvent(CPUTKey key, CPUTKeyState state){UNREFERENCED_PARAMETER(key); return CPUT_EVENT_UNHANDLED;}
    virtual CPUTEventHandledCode HandleMouseEvent(int x, int y, int wheel, CPUTMouseState state, CPUTEventID message){UNREFERENCED_PARAMETER(x);UNREFERENCED_PARAMETER(y);UNREFERENCED_PARAMETER(wheel);UNREFERENCED_PARAMETER(state);return CPUT_EVENT_UNHANDLED;}
    
    //CPUTControl
    void GetDimensions(int &width, int &height);
    void GetPosition(int &x, int &y);    

    // CPUTControl
    virtual void SetPosition(int x, int y);
    void SetEnable(bool in_bEnabled);
    bool ContainsPoint(int x, int y) {UNREFERENCED_PARAMETER(x);UNREFERENCED_PARAMETER(y);return false;}

    // CPUTText
    CPUTResult SetText(std::string const& String, float depth=0.5f);
    void SetColor(float r, float g, float b, float a);
    
    float4 GetColor();
    int GetOutputVertexCount();

    // Register assets
    CPUTResult RegisterInstanceData();
    static CPUTResult RegisterStaticResources();
    static CPUTResult UnRegisterStaticResources();

    // draw
    void Draw(CPUTGUIVertex *pVertexBufferMirror, UINT *pInsertIndex, UINT pMaxBufferSize);

protected:

    // button should self-register with the GuiController on create
    CPUTText(CPUTFont *pFont);    
    CPUTText(std::string const& String, CPUTControlID id, CPUTFont *pFont);

    // instance variables
    CPUT_POINT          mPosition;
    CPUT_RECT           mDimensions;
    CPUT_SIZE           mQuadSize;
    CPUTGUIControlState mStaticState;
        
    UINT mVertexStride;
    UINT mVertexOffset;
    CPUTFont           *mpFont;

    // uber-buffer
    std::string mStaticText;
    float mZDepth;
    CPUTGUIVertex *mpMirrorBuffer;
    int mNumCharsInString;
    static CPUT_SIZE mpStaticIdleImageSizeList[500]; // todo: size for #chars in font
    static CPUT_SIZE mpStaticDisabledImageSizeList[500]; // todo: size for #chars in font
    

    // helper functions
    void InitialStateSet();
    void ReleaseInstanceData();
    void Recalculate();
};




#endif //#ifndef __CPUTTEXT_H__