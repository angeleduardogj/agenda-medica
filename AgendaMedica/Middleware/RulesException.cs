namespace AgendaMedica.Middleware;

public class RulesException : Exception
{
    public int StatusCode { get; }

    public RulesException(string mensaje, int statusCode = 400)
        : base(mensaje)
    {
        StatusCode = statusCode;
    }
}
