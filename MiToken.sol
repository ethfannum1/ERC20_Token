
/*  -----------------------------------------------------------------------------------------------
    Los ERC20 establecen las funcionalidades más bajas/más básicas de un Token.

    https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
    https://eips.ethereum.org/EIPS/eip-20

    Y sobre este, se construyen otros smart contracts, que generan una mayor dinámica de negocio: 
    como por ejemplo la venta de Tokens = una ITO (Initial Token Offering). 
    ----------------------------------------------------------------------------------------------- 
*/

pragma solidity ^0.5.0;


contract MiToken {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    // ========================================================================================================================
    // FUNCIONES DE TIPO GETTER
    // ========================================================================================================================
    /* 
    La especificación ERC20 dice que entre las distintas funciones que hay que generar, están las siguientes funciones:

        - name --> nombre del token. 
                   https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#name
                   
        - symbol --> símbolo del token. 
                     https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#symbol

        - decimals --> número de decimales.
                       https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#decimals

        - totalSupply --> número de unidades enteras existentes de ese Token.
                          https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#totalsupply

        - balanceOf --> balance de tokens cada cuenta.
                        https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#balanceof

        - allowance --> retorna la cantidad de Tokens que una persona address puede transferir de la dirección propietaria de otra persona address.
                        https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#allowance
    
    Pero en lugar de definir estas funciones como funciones, se pueden definir como variables de estado (scope = variables globales) públicas:
    en ese caso el propio compilador genera para cada una, una función getter con el mismo nombre.  
    */ 

    // Nombre del Token (Ejemplo: "Basic Attention Token")
    string public name;
    // Símbolo del Token (Ejemplo: "BAT")
    string public symbol;

    
    // Número de decimales.
    uint8 public decimals;
    // Total Supply.
    uint256 public totalSupply;

    // Balance de tokens que tiene cada cuenta. 
    /* 
        Se expresa en unidades mínimas de Token. 
        Por ejemplo, la dirección address inicial creadora del contrato, que tendrá 100.000.000 (de unidades enteras de Token),
        aquí guardará el valor 100.000.000.000.000.000.000.000.000 (de unidades mínimas de Token)    
    */
    mapping(address => uint256) public balanceOf; 

    // Permitir a otra persona (address) gestionar los Tokens que pertenecen a su dueño (otra address distinta).
    // Address 1 = dirección de la persona dueña de los Tokens. 
    // Address 2 = dirección de la persona a quien se permite que maneje una cantidad de Tokens.
    // uint256 = cantidad de Tokens permitida a manejar a esa persona.
    mapping(address => mapping(address => uint256)) public allowance; // También se expresa en unidades mínimas de Token. 



    // ------------------------------------------------------------------------------------------------------------------------


    constructor() public {
        name = "Mi Token";

        symbol = "MIT";

        decimals = 18; // Siguiendo el mismo patrón que ETH.

        /*
            ** = operador exponencial.

            100.000.000 de unidades enteras de Token.
            100.000.000.000.000.000.000.000.000 de unidades mínimas de Token. (al ser 18 decimales)
        
            El totalSupply se expresa en unidades mínimas de Token.
        */ 
        totalSupply = 100000000 * (uint256(10) ** decimals); 

        // Establecer el dueño de los Tokens.
        balanceOf[msg.sender] = totalSupply; 
    }

    
    // ========================================================================================================================
    // FUNCIONES DE TIPO SETTER = las que cambian los valores de las variables del estado del smart contract.
    // ========================================================================================================================

    /*  Para los métodos se especifica:
        "Callers MUST handle false from returns (bool success). Callers MUST NOT assume that false is never returned!"
        Pero Alberto Lasa parece que no tiene en cuenta esto y siempre retorna true. 
    */


    /*  ---------------------------------------
        Transfiere fondos de una cuenta a otra.    
        ---------------------------------------
        Transfiere una cantidad de Tokens (_value) propiedad de quien llama a la función (msg.sender), a otra cuenta (_to).
        Seguir las especificaciones:
        https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer

        La cantidad de Tokens a transferir, hay que especificarla en unidades mínimas de Token.
        Si por ejemplo quiero enviar 500 Tokens, el parámetro (_value) ha de ser 500.000.000.000.000.000.000
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // Comprobar que quien va a hacer la transferencia, tiene suficiente saldo.
        require(balanceOf[msg.sender] >= _value);
        // Quitarle a quien transfiere, el número de tokens transferidos.
        balanceOf[msg.sender] -= _value;
        // Ponerle a quien recibe, el número de tokens transferidos.
        balanceOf[_to] += _value;
        // Evento de transferencia.
        emit Transfer(msg.sender, _to, _value);
        //
        return(true);
    }


    /*  ------------------------------------------------------
        Permite a otra persona (address) gestionar mis fondos.
        ------------------------------------------------------ 
        No quiere decir que le esté transfiriendo ese número de tokens a esa persona (address), 
        sino que esa persona puede hacer un traspaso de ese número de tokens a otra persona en mi nombre.
        _spender = la persona autorizada a realizar un traspaso.
        _value = cantidad máxima permitida que puede traspasar. Se expresa en unidades mínimas de Token.   
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        /*  Se prodría pensar en poner aquí un require, para comprobar que el dueño de los Tokens, realmente tiene la cantidad de Tokens que dice tener.
            Pero no se pone porque aquí aún no se están transfiriendo Tokens, sino sólo dando autorización para una posible futura transferencia.
            Se controlará con ese require, que realmente el dueño tiene los Tokens que dice tener, pero en la función de transferencia, no aquí.

            Por ejemplo: yo puedo autorizar a otra persona (address) a manejar 1000 de mis Tokens. Puede que yo no tenga los 1000 Tokens esos ahora, pero mañana sí.
            El require para comprobar que esos fondos los tengo realmente, se pone en el momento concreto cuando esa persona a la que he autorizado, va a realziar la transferencia.
        */   

        // Asignar la persona autorizada, y qué cantidad de Tokens está autorizada a transferir.
        allowance[msg.sender][_spender] = _value;

        // Evento lanzado en toda llamada correcta a approve.
        emit Approval(msg.sender, _spender, _value);

        return(true);
    }



    /*  ------------------------------------------------------------------------------
        Realiza la transferencia de Tokens, desde una cuenta supuestamente autorizada.
        ------------------------------------------------------------------------------
        Realiza una transferencia de una cantidad de Tokens (_value) que son propiedad de una dirección address (_from),
        desde una dirección address (msg.sender) supuestamente autorizada a transferir esa cantidad de Tokens, 
        a otra dirección address (_to).

        (_value) Se expresa en unidades mínimas de Token. 
        
        https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transferfrom      
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // Ahora sí, hay que comprobar que la address (_from) dueña de los Tokens, tiene la cantidad de Tokens que se van a transferir.
        require(balanceOf[_from] >= _value);

        // Ahora comprobar que esa dirección address (msg.sender) está autorizada por el dueño de los tokens (_from), a transferir esa cantidad.
        require(allowance[_from][msg.sender] >= _value);

        // Transferencia.
        // Al dueño de los Tokens se le resta la cantidad que se va a transferir.
        balanceOf[_from] -= _value;
        // A quien recibe los Tokens se le suma la cantidad.
        balanceOf[_to] += _value;
        // A la dirección autorizada a transferir, se le restan los Tokens que transfiere.
        allowance[_from][msg.sender] -= _value;

        // MUST trigger when tokens are transferred, including zero value transfers.
        emit Transfer(_from, _to, _value);

        return(true);
    }

}


