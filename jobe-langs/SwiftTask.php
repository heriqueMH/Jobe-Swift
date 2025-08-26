<?php
namespace Jobe;

/**
 * Swift
 * Compila com swiftc -> gera binário ./prog e executa.
 */
class SwiftTask extends LanguageTask
{
    // Caminho do compilador dentro do contêiner Docker
    const SWIFT_BIN_PATH = '/opt/swift/usr/bin/';

    public function __construct($filename, $input, $params)
    {
        parent::__construct($filename, $input, $params);
        $this->default_params['compileargs'] = array();
        $this->default_params['linkargs']    = array();
    }

    public static function getVersionCommand()
    {
        return array(self::SWIFT_BIN_PATH . 'swiftc --version', '/version ([0-9.]+)/');
    }
    public function compile()
    {
        $this->executableFileName = $execFileName = 'prog';
        $compileargs = $this->getParam('compileargs');
        $linkargs    = $this->getParam('linkargs');

        $cmd = self::SWIFT_BIN_PATH . 'swiftc '
             . implode(' ', $compileargs) . ' '
             . escapeshellarg($this->sourceFileName)
             . ' -o ' . escapeshellarg($execFileName) . ' '
             . implode(' ', $linkargs);

        list($output, $this->cmpinfo) = $this->runInSandbox($cmd);
    }

    public function defaultFileName($sourcecode)
    {
        return 'prog.swift';
    }

    public function getExecutablePath()
    {
        return './' . $this->executableFileName;
    }
      public function getTargetFile()
    {
        return '';
    }
}
