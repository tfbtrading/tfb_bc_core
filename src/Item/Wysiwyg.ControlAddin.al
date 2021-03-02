controladdin Wysiwyg
{
    RequestedHeight = 250;
    MinimumHeight = 250;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts = 'Editor/Scripts/ckeditor.js', 'Editor/Scripts/MainScript.js';
    StartupScript = 'Editor/Scripts/startupScript.js';
    RecreateScript = 'Editor/Scripts/recreateScript.js';
    RefreshScript = 'Editor/Scripts/refreshScript.js';


    event ControlReady();
    event SaveRequested(data: Text);
    event ContentChanged();
    event OnAfterInit();

    procedure Init();
    procedure Load(data: Text);
    procedure RequestSave();
    procedure SetReadOnly(readonly: boolean);
}