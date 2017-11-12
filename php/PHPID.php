<?php
namespace PHPCD;

use Psr\Log\LoggerInterface as Logger;
use Lvht\MsgpackRpc\Server as RpcServer;
use Lvht\MsgpackRpc\Handler as RpcHandler;

class PHPID implements RpcHandler
{
    /**
     * @var RpcServer
     */
    private $server;

    /**
     * @var Logger
     */
    private $logger;

    private $root;

    public function __construct($root, Logger $logger)
    {
        $this->root = $root;
        $this->logger = $logger;
    }

    public function setServer(RpcServer $server)
    {
        $this->server = $server;
    }

    /**
     * update index for one class
     *
     * @param string $class_name fqdn
     */
    public function update($class_name)
    {
        list($parent, $interfaces) = $this->getClassInfo($class_name);

        $this->_update($class_name, $parent, $interfaces);
    }

    private function _update($class_name, $parent, $interfaces)
    {
        if ($parent) {
            $this->updateParentIndex($parent, $class_name);
        }
        foreach ($interfaces as $interface) {
            $this->updateInterfaceIndex($interface, $class_name);
        }
    }

    /**
     * Fetch an interface's implemation list,
     * or an abstract class's child class.
     *
     * @param string $name name of interface or abstract class
     * @param bool $is_interface
     *
     * @return [
     *   'full class name 1',
     *   'full class name 2',
     * ]
     */
    public function ls($name, $is_interface = false)
    {
        return self::lsByRoot($this->root, $name, $is_interface);
    }

    /**
     * @param string $root
     * @param string $name
     * @param bool $is_interface
     * @return array
     */
    public static function lsByRoot($root, $name, $is_interface)
    {
        $base_path = $is_interface ?
            self::getInterfacesDirImpl($root) :
            self::getExtendsDirImpl($root);

        $path = $base_path . '/' . self::getIndexFileName($name);
        if (!is_file($path)) {
            return [];
        }

        $list = json_decode(file_get_contents($path));
        if (!is_array($list)) {
            return [];
        }

        sort($list);

        return $list;
    }

    /**
     * Fetch and save class's interface and parent info
     * according the autoload_classmap.php file
     *
     * @param bool $is_force overwrite the exists index
     */
    public function index()
    {
        $this->initIndexDir();

        $files = $this->searchPhpFileList($this->root);

        $count = count($files);
        $last = 0;
        for ($i = 0; $i < $count; $i++) {
             $classes = Parser::getParentAndInterfaces($files[$i]);
             foreach ($classes as $name => $class) {
                 $this->_update($name, $class['extends'], $class['implements']);
             }

             $percent = number_format(($i + 1) / $count * 100);
             if ($percent != $last) {
                 $this->server->call('vim_command', ["redraw | echo \"indexing $percent%\""]);
                 $last = $percent;
             }
        }
        $this->server->call('vim_command', ["redraw | echo \"\""]);
    }

    public static function searchPhpFileList($folder)
    {
        $iterator = new \RecursiveDirectoryIterator($folder);
        $iterator = new \RecursiveIteratorIterator($iterator);
        $iterator = new \RegexIterator($iterator, '/\.php$/i', \RegexIterator::MATCH);

        $files = [];
        foreach ($iterator as $info) {
            $files[] = $info->getPathName();
        }

        return $files;
    }

    private static function getIndexDir($root)
    {
        return $root . '/.phpcd';
    }

    private function getInterfacesDir()
    {
        return self::getInterfacesDirImpl($this->root);
    }

    private static function getInterfacesDirImpl($root)
    {
        return self::getIndexDir($root) . '/interfaces';
    }

    private function getExtendsDir()
    {
        return self::getExtendsDirImpl($this->root);
    }

    private static function getExtendsDirImpl($root)
    {
        return self::getIndexDir($root) . '/extends';
    }

    private function initIndexDir()
    {
        $extends_dir = $this->getExtendsDir();
        if (!is_dir($extends_dir)) {
            mkdir($extends_dir, 0700, true);
        }

        $interfaces_dir = $this->getInterfacesDir();
        if (!is_dir($interfaces_dir)) {
            mkdir($interfaces_dir, 0700, true);
        }
    }

    private function updateParentIndex($parent, $child)
    {
        $index_file = $this->getExtendsDir() . '/' . $this->getIndexFileName($parent);
        $this->saveChild($index_file, $child);
    }

    private function updateInterfaceIndex($interface, $implementation)
    {
        $index_file = $this->getInterfacesDir() . '/' . $this->getIndexFileName($interface);
        $this->saveChild($index_file, $implementation);
    }

    private function saveChild($index_file, $child)
    {
        $index_directory = dirname($index_file);

        if (!is_dir($index_directory)) {
            mkdir($index_directory, 0755, true);
        }

        if (is_file($index_file)) {
            $childs = json_decode(file_get_contents($index_file));
        } else {
            $childs = [];
        }

        $childs[] = $child;
        $childs = array_unique($childs);
        file_put_contents($index_file, json_encode($childs));
    }

    private static function getIndexFileName($name)
    {
        return str_replace("\\", '_', $name).'.json';
    }

    private function getClassInfo($name) {
        try {
            $reflection = new \ReflectionClass($name);

            $parent = $reflection->getParentClass();
            if ($parent) {
                $parent = $parent->getName();
            }

            $interfaces = array_keys($reflection->getInterfaces());

            return [$parent, $interfaces];
        } catch (\ReflectionException $e) {
            return [null, []];
        }
    }
}
