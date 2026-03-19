using System.Text.Json;
using Microsoft.Data.SqlClient;

namespace AgendaMedica.Middleware;

public class ErrorMiddleware(RequestDelegate next, ILogger<ErrorMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (RulesException ex)
        {
            logger.LogWarning("Error de negocio: {Mensaje}", ex.Message);
            await Responder(context, ex.StatusCode, ex.Message);
        }
        catch (SqlException ex) when (ex.Number >= 50000)
        {
            logger.LogWarning("Error de base de datos (Regla de negocio): {Mensaje}", ex.Message);
            
            int statusCode = 400;
            
            if (ex.Message.Contains("no existe", StringComparison.OrdinalIgnoreCase) || ex.Message.Contains("no se encontró", StringComparison.OrdinalIgnoreCase))
            {
                statusCode = 404;
            }
            else if (ex.Message.Contains("ya existe", StringComparison.OrdinalIgnoreCase)
                || ex.Message.Contains("solapa", StringComparison.OrdinalIgnoreCase)
                || ex.Message.Contains("ya tiene una cita", StringComparison.OrdinalIgnoreCase))
            {
                statusCode = 409;
            }

            await Responder(context, statusCode, ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error inesperado");
            await Responder(context, 500, "Ocurrió un error interno. Intente más tarde.");
        }
    }

    private static async Task Responder(HttpContext context, int status, string mensaje)
    {
        context.Response.StatusCode  = status;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsync(
            JsonSerializer.Serialize(new { status, error = mensaje })
        );
    }
}
