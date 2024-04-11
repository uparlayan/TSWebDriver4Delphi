unit uExampleTSWebDriver;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls,  System.IOUtils, Vcl.ToolWin,
  Vcl.ComCtrls, Vcl.Buttons, System.JSON, REST.Json,

  TSWebDriver,
  TSWebDriver.IElement,
  TSWebDriver.Interfaces,
  TSWebDriver.By,
  TSWebDriver.IBrowser;

type
  TFrmMain = class(TForm)
    MemLog: TMemo;
    btnNavigateTo: TButton;
    btnExecuteScript: TButton;
    btnExample4: TButton;
    btnExample5: TButton;
    btnExample1: TButton;
    btnExample2: TButton;
    btnExample3: TButton;
    btnExample6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnExecuteScriptClick(Sender: TObject);
    procedure btnExample4Click(Sender: TObject);
    procedure btnExample5Click(Sender: TObject);
    procedure btnExample2Click(Sender: TObject);
    procedure btnExample3Click(Sender: TObject);
    procedure btnNavigateToClick(Sender: TObject);
    procedure btnExample1Click(Sender: TObject);
    procedure btnExample6Click(Sender: TObject);
  private
    { Private declarations }
    FDriver: ITSWebDriverBase;
    aBrowserDriver: ITSWebDriverBrowser;
    FBy: TSBy;
    procedure Run(AProc: TProc; AUrl: string = ''; ACloseSection: Boolean = True);
    procedure ExampleLoginAndScrap;
    procedure ExampleDynamicElement;
    procedure ExampleGitHubBio;
    procedure ExampleGitHubFollowers;
    procedure ExampleChromeSearch;
  public
   { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  FDriver := TTSWebDriver.New.Driver();
  //FDriver.Options.DriverPath('.\a\b\c\webdriver.exe');
  //FDriver.Options.DriverPath('C:\Users\RAD\Desktop\WebDriver\chromedriver.exe');  // Type the full path to chromedriver.exe (or msedgedriver.exe or webdriver.exe or similar...)
  FDriver.Options.DriverPath('C:\Users\RAD\Desktop\WebDriver\msedgedriver.exe');  // Type the full path to msedgedriver.exe (or chromedriver.exe or webdriver.exe or similar...)

  // use this endpoint for chrome web driver download links.
  // Find your chrome version in Endpoint and pull the appropriate one.
  // https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json

  // or for edge browser web driver
  // https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/?form=MA13LH#downloads

  aBrowserDriver := FDriver.Browser().Edge();  // or .Chrome()
  aBrowserDriver
    .AddArgument('window-size', '1000,800')
    .AddArgument('window-minimize', '')
    //.AddArgument('user-data-dir', 'E:/Dev/Delphi/TSWebDriver4Delphi/example/cache')
  ;

  FDriver.Start();

  // Added abilities;
  // https://w3c.github.io/webdriver/#minimize-window
end;

procedure TFrmMain.Run(AProc: TProc; AUrl: string = ''; ACloseSection: Boolean = True);
begin
  MemLog.Clear();

  aBrowserDriver.NewSession();

  aBrowserDriver.MinimizeWindow();

  if not AUrl.IsEmpty then
    aBrowserDriver.NavigateTo(AUrl);


  aBrowserDriver.WaitForPageReady();

  AProc();

  if ACloseSection then
    aBrowserDriver.CloseSession();
end;

procedure TFrmMain.btnExample1Click(Sender: TObject);
begin
  Self.Run(
    ExampleLoginAndScrap,
    'https://www.saucedemo.com'
  );
end;

procedure TFrmMain.btnExample2Click(Sender: TObject);
begin
  Self.Run(
    ExampleDynamicElement,
    'https://www.selenium.dev/selenium/web/dynamic.html'
  );
end;

procedure TFrmMain.btnExample3Click(Sender: TObject);
begin
  Self.Run(
    ExampleGitHubBio,
    'https://letcode.in/elements'
  );
end;

procedure TFrmMain.btnExample4Click(Sender: TObject);
begin
  Self.Run(
    ExampleChromeSearch,
    'https://www.mercadolivre.com.br'
  );
end;

procedure TFrmMain.btnExample5Click(Sender: TObject);
begin
  Self.Run(
    ExampleGitHubFollowers,
    'https://gh-users-search.netlify.app'
  );
end;

procedure TFrmMain.btnExecuteScriptClick(Sender: TObject);
begin
  MemLog.Text :=
    aBrowserDriver.ExecuteSyncScript(
      InputBox('Script', '', 'return document.title'));
end;

procedure TFrmMain.btnNavigateToClick(Sender: TObject);
begin
  Self.Run(procedure
          begin
            aBrowserDriver.NavigateTo(
              InputBox('Url', '', 'https://github.com/uparlayan'));
          end,
  '', False);
end;

procedure TFrmMain.btnExample6Click(Sender: TObject);
begin
  Self.Run(
    procedure
    var
      LCheckbox: ITSWebDriverElement;
    begin
      LCheckbox := aBrowserDriver.FindElement(FBy.XPath('//input[@id=''checky'']'));

      MemLog.Lines.Append(LCheckbox.GetAttribute('checked'));
      LCheckbox.Click();
      MemLog.Lines.Append(LCheckbox.GetAttribute('checked'));
    end,
    'file:///' + TPath.GetFullPath('..\..\test\mocks\formPage.html').Replace('\', '/')
  );
end;

procedure TFrmMain.ExampleChromeSearch;
var
  LElement: ITSWebDriverElement;
  LElements: TTSWebDriverElementList;
begin
  try
    LElement := aBrowserDriver.FindElement(FBy.Name('as_word'));

    LElement.SendKeys('Macbook');
    // Send Enter key code > https://www.w3.org/TR/webdriver2/#element-send-keys
    LElement.SendKeys('\uE007');

    aBrowserDriver.WaitForPageReady();

    LElements := aBrowserDriver.FindElements(FBy.ClassName('ui-search-layout__item'));

    MemLog.Lines.Append('I finded ' + LElements.Count.ToString() + ' items');

    for LElement in LElements do
      with MemLog.Lines do
      begin
        AddPair('Name',  LElement.FindElement(FBy.TagName('h2')).GetText());
        AddPair('Price', LElement.FindElement(FBy.ClassName('ui-search-price__second-line')).GetText());
        Append('-------------------------');
      end;
  finally
    FreeAndNil(LElements);
  end;
end;

procedure TFrmMain.ExampleDynamicElement;
var
  LElement: ITSWebDriverElement;
begin
  LElement := aBrowserDriver.FindElement(FBy.Id('adder'));

  LElement.Click();

  aBrowserDriver.WaitForSelector('#box0');

  LElement := aBrowserDriver.FindElement(FBy.Id('box0'));

  with MemLog.Lines do
  begin
    AddPair('Displayed', BoolToStr(LElement.Displayed(), True)).Add('');
    AddPair('Property style', LElement.GetProperty('style')).Add('');
    AddPair('Property innerHtml', LElement.GetProperty('innerHtml')).Add('');
    AddPair('CssValue "display"', LElement.GetCssValue('display')).Add('');
    AddPair('CssValue "width"', LElement.GetCssValue('width')).Add('');
    AddPair('CssValue "background-color"', LElement.GetCssValue('background-color')).Add('');
    AddPair('GetText', LElement.GetText()).Add('');
    AddPair('GetTagName', LElement.GetTagName()).Add('');
    AddPair('GetEnabled', BoolToStr(LElement.GetEnabled, True)).Add('');
    AddPair('GetPageSource', aBrowserDriver.GetPageSource()).Add('');
  end;
end;

procedure TFrmMain.ExampleGitHubBio;
begin
  aBrowserDriver.FindElement(FBy.Name('username')).SendKeys('uparlayan');

  aBrowserDriver.FindElement(FBy.ID('search')).Click();

  aBrowserDriver.WaitForSelector('.media');

  with aBrowserDriver.FindElement(FBy.CssSelector('.media-content > span')) do
  begin
    MemLog.Lines.AddPair('GitHub bio', GetText());
  end;
end;

procedure TFrmMain.ExampleGitHubFollowers;
var
  LElement: ITSWebDriverElement;
  LElements: TTSWebDriverElementList;
begin
  LElements := aBrowserDriver.FindElements(FBy.CssSelector('.followers > article'));

  for LElement in LElements do
    with MemLog.Lines do
    begin
      AddPair('Name', LElement.FindElement(FBy.TagName('h4')).GetText());
      AddPair('Link', LElement.FindElement(FBy.TagName('a')).GetText());
      Append('-------------------------');
    end;

  FreeAndNil(LElements);
end;

procedure TFrmMain.ExampleLoginAndScrap;
var
  LElement: ITSWebDriverElement;
  LElements: TTSWebDriverElementList;
begin
  try
    aBrowserDriver.FindElement(FBy.Name('user-name')).SendKeys('standard_user');
    aBrowserDriver.FindElement(FBy.ID('password')).SendKeys('secret_sauce');
    aBrowserDriver.FindElement(FBy.Name('login-button')).Click();

    LElements := aBrowserDriver.FindElements(FBy.ClassName('inventory_item'));

    for LElement in LElements do
      with MemLog.Lines do
      begin
        AddPair('Name'       , LElement.FindElement(FBy.ClassName('inventory_item_name')).GetText());
        AddPair('Description', LElement.FindElement(FBy.ClassName('inventory_item_desc')).GetText());
        AddPair('Price'      , LElement.FindElement(FBy.ClassName('inventory_item_price')).GetText());
        Append('-------------------------');
      end;
  finally
    FreeAndNil(LElements);
  end;
end;

end.

